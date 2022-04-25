# Funções úteis

## Equivalente ao mod() do glsl
```hlsl
float2 mod(float2 x, float2 y)
{
	return x - y * floor(x/y);
}
```

## grid hexagonal

```hls
float2 hexGrid(float2 uv)
{
	float2 r = float2(1., 1.73);
	float2 h = r*.5;
	float2 a = mod(uv, r) - h;
	float2 b = mod(uv - h, r) - h;
	float2 gv = length(a) < length(b)? a:b;
	return gv;
}
```
### uso
```hlsl
hexGrid(uv * 5.);
```
