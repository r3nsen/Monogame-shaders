# RGB para HSV
```hlsl
float3 RGBtoHSV(float3 rgb)
{
	float hue = 0;
	float sat = 0;
	float val = 0;

	float cmax = max(rgb.r, max(rgb.g, rgb.b));
	float cmin = min(rgb.r, min(rgb.g, rgb.b));
	float cdiff = cmax - cmin;

	// hue
	if (cdiff == 0.) hue = 0.;
	else if (cmax == rgb.r) hue = ((60 * (rgb.g - rgb.b) / cdiff) + 360.) % 360.;
	else if (cmax == rgb.g) hue = ((60 * (rgb.b - rgb.r) / cdiff) + 120.) % 360.;
	else if (cmax == rgb.b) hue = ((60 * (rgb.r - rgb.g) / cdiff) + 240.) % 360.;

	// saturation
	if (cmax == 0.)
		sat = 0;
	else sat = (cdiff / cmax);

	// value
	val = cmax;
	return float3(hue, sat, val);
}
```
#HSV to RGB
```hlsl
float3 HSVtoRGB(float3 hsv)
{
	float hue = hsv.r;
	float sat = hsv.g;
	float val = hsv.b;

	int h = (int)floor(hue / 60.);
	float f = hue / 60. - h;
	float p = val * (1. - sat);
	float q = val * (1. - f * sat);
	float t = val * (1. - (1. - f) * sat);
	
	float3 rgb = 0;
	
	// val q p p t val
	if (h == 0)
	{
		rgb.r = val;
		rgb.g = t;
		rgb.b = p;
	}
	if (h == 1)
	{
		rgb.r = q;
		rgb.g = val;
		rgb.b = p;
	}
	if (h == 2)
	{
		rgb.r = p;
		rgb.g = val;
		rgb.b = t;
	}
	if (h == 3)
	{
		rgb.r = p;
		rgb.g = q;
		rgb.b = val;
	}
	if (h == 4)
	{
		rgb.r = t;
		rgb.g = p;
		rgb.b = val;
	}
	if (h == 5)
	{
		rgb.r = val;
		rgb.g = p;
		rgb.b = q;
	}
	return rgb;
}
```

# normalize
```hlsl
float normalize(float value, float vmin, float vmax, float newMin, float newMax)
{
	return (value - minv) * ((newMax - newMin) / (maxv - minv)) + newMin;
}
```
```hlsl
float4 normalizePS(VertexShaderOutput input) : COLOR
{
	float4 cor = (tex2D(tex_samp, input.tex) + tex2D(tex_samp2, input.tex));
	cor.r = (cor.r - minv) * ((newMax - newMin) / (maxv - minv)) + newMin;
	cor.g = (cor.g - minv) * ((newMax - newMin) / (maxv - minv)) + newMin;
	cor.b = (cor.b - minv) * ((newMax - newMin) / (maxv - minv)) + newMin;
	return cor;
}
```

# 8 bits truncation
```hlsl
float4 _8bitsPS(VertexShaderOutput input) : COLOR
{
	float4 cor = (tex2D(tex_samp, input.tex));// +tex2D(tex_samp2, input.tex));

	cor.r = trunc(cor.r * 7.+.5 ) / 7.; //normalize(cor.r * 255, 0, 255, 0, 8) / 8.;
	cor.g = trunc(cor.g * 7.+.5 ) / 7.; //normalize(cor.g * 255, 0, 255, 0, 8) / 8.;
	cor.b = trunc(cor.b * 3.+.5 ) / 3.; //normalize(cor.b * 255, 0, 255, 0, 3) / 3.;
	return cor;
}
```
# truncate
```hlsl
float4 truncatePS(VertexShaderOutput input) : COLOR
{
	float4 cor = (tex2D(tex_samp, input.tex) + tex2D(tex_samp2, input.tex));
	cor.r = max(newMin, min(cor.r, newMax));
	cor.g = max(newMin, min(cor.g, newMax));
	cor.b = max(newMin, min(cor.b, newMax));
	return cor;
}
```
# wrap
```hlsl
float4 wrapPS(VertexShaderOutput input) : COLOR
{
	float4 cor = (tex2D(tex_samp, input.tex) + tex2D(tex_samp2, input.tex));
	cor.r = ((cor.r - newMin) % (newMax - newMin)) + newMin;
	cor.g = ((cor.g - newMin) % (newMax - newMin)) + newMin;
	cor.b = ((cor.b - newMin) % (newMax - newMin)) + newMin;
	return cor;
}
```
# show hsv
```hlsl
float4 hsv(VertexShaderOutput input) : COLOR
{
	float4 cor = tex2D(tex_samp, input.tex);
	// to hsv
	float3 hsv = RGBtoHSV(cor.rgb);
	hsv.x /= 360.;
	return float4(hsv,1.);
}
```
# hue shift
```hlsl
float4 hueShiftPS(VertexShaderOutput input) : COLOR
{
	float4 cor = tex2D(tex_samp, input.tex);
	// to hsv
	float3 hsv = RGBtoHSV(cor.rgb);

	// operation
	hsv.r = (hsv.r + timer / 10.) % 360.;

	// to rgb	
	cor.rgb = HSVtoRGB(hsv);

	return cor;
}
```
