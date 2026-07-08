# phase 7: quantization (bf16 → int8)

**goal:** convert trained bf16 checkpoints into int8 per-channel quantized models for android deployment.

**depends on:** phase 6

## approach

post-training quantization (ptq) with per-channel weight quantization. weights are quantized to int8 with separate scale per output channel. activations remain in fp32/bf16 at runtime (the android inference engine dequantizes per channel on-the-fly).

future work: quantization-aware training (qat) for lower bit-widths.

## files

| file | purpose |
|------|---------|
| `pkg/jax/quant/main.zig` | module root |
| `pkg/jax/quant/calibrate.zig` | calibration data → activation statistics |
| `pkg/jax/quant/quantize.zig` | weight quantization + safetensors export |
| `pkg/jax/quant/test/main.zig` | tests |

## calibration strategy

1. run a small representative dataset through the model (a few hundred samples)
2. collect per-channel activation statistics (min, max, mean, std) for each linear/conv weight
3. compute quantization scale factors:
   ```
   scale = (max - min) / 255
   zero_point = round(-min / scale)
   ```
4. scales and zero_points are stored per output channel

for depthwise conv layers: per-channel quantization along the output channel dimension (d_model).

for linear layers: per-channel quantization along the output dimension.

## quantize.zig — weight quantization

```zig
pub const QuantizedTensor = struct {
    qdata: []i8,           // quantized int8 weights
    scales: []f32,         // per-channel scale factors
    zero_points: []i8,     // per-channel zero points
    shape: Shape,
    dtype: pjrt.BufferType,  // original dtype (before quantization)
};

pub fn quantizeWeights(
    params: *Module,           // trained bf16 parameters
    calibration: *Calibration,  // computed scales/zero_points
    allocator: std.mem.Allocator,
) !QuantizedModel

pub fn saveQuantized(
    path: []const u8,
    model: *QuantizedModel,
    metadata: ?[]const u8,
) !void
```

## checkpoint format (int8 safetensors)

same safetensors format as training, but with int8 data and additional metadata:

```json
{
    "model.conv_block.0.w_proj.weight": {
        "dtype": "I8",
        "shape": [3072, 1024],
        "data_offsets": [0, 3145728]
    },
    "model.conv_block.0.w_proj.scales": {
        "dtype": "F32",
        "shape": [3072],
        "data_offsets": [3145728, 3158016]
    },
    "model.conv_block.0.w_proj.zero_points": {
        "dtype": "I8",
        "shape": [3072],
        "data_offsets": [3158016, 3161088]
    }
}
```

each quantized weight tensor is stored as three tensors in the safetensors file:
- `name` — the int8 quantized data
- `name.scales` — per-channel float32 scale factors
- `name.zero_points` — per-channel int8 zero points

the `__metadata__` section records the quantization scheme:
```json
"__metadata__": {
    "quantization": "per_channel_symmetric",
    "source_format": "BF16",
    "model_config": "..."
}
```

## files produced

| file | contents |
|------|----------|
| `model.int8.safetensors` | quantized weights + scales + zero_points |
| `model.int8.json` | model architecture config (for the inference engine) |

the json config file records `LFMConfig` fields so the inference engine knows architecture parameters without parsing safetensors.

## cli integration

a `jax quantize` subcommand in `cmd/jax/main.zig`:

```
jax quantize --input=<bf16-checkpoint> --output=<int8-checkpoint> --calibration=<data>
```

## tests

- `quantize.linear` — quantize a single linear layer, verify round-trip error is within expected range
- `quantize.conv` — quantize depthwise conv weights
- `quantize.checkpoint` — save + reload quantized safetensors, verify metadata and byte offsets
- `calibrate.range` — verify calibration produces reasonable scale factors
