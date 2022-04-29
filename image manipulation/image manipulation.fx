#if OPENGL
#define SV_POSITION POSITION
#define VS_SHADERMODEL vs_3_0
#define PS_SHADERMODEL ps_3_0
#else
#define VS_SHADERMODEL vs_4_0
#define PS_SHADERMODEL ps_4_0
#endif

matrix WorldViewProjection;
float minv, maxv, newMin, newMax;
float timer;

Texture2D tex;
sampler2D tex_samp = sampler_state
{
	Texture = <tex>;
};
Texture2D tex2;
sampler2D tex_samp2 = sampler_state
{
	Texture = <tex2>;
};
struct VertexShaderInput
{
	float4 position : POSITION0;
	float4 color : COLOR0;
	float2 tex: TEXCOORD0;
};
struct VertexShaderOutput
{
	float4 position : SV_POSITION;
	float4 color : COLOR0;
	float2 tex: TEXCOORD0;
};


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

float normalize(float value, float vmin, float vmax, float newMin, float newMax)
{
	return (value - minv) * ((newMax - newMin) / (maxv - minv)) + newMin;
}

VertexShaderOutput MainVS(in VertexShaderInput input)
{
	VertexShaderOutput output = (VertexShaderOutput)0;

	output.position = mul(input.position, WorldViewProjection);
	output.color = input.color;
	output.tex = input.tex;

	return output;
}
float4 MainPS(VertexShaderOutput input) : COLOR
{
	return tex2D(tex_samp, input.tex) * input.color;
}

float4 _8bitsPS(VertexShaderOutput input) : COLOR
{
	float4 cor = (tex2D(tex_samp, input.tex));// +tex2D(tex_samp2, input.tex));

	cor.r = trunc(cor.r * 7.+.5 ) / 7.; //normalize(cor.r * 255, 0, 255, 0, 8) / 8.;
	cor.g = trunc(cor.g * 7.+.5 ) / 7.; //normalize(cor.g * 255, 0, 255, 0, 8) / 8.;
	cor.b = trunc(cor.b * 3.+.5 ) / 3.; //normalize(cor.b * 255, 0, 255, 0, 3) / 3.;
	return cor;
}

float4 _8bitsHuePS(VertexShaderOutput input) : COLOR
{
	float pi = 3.141592653589793238462643383279;
	float4 cor = (tex2D(tex_samp, input.tex));// +tex2D(tex_samp2, input.tex));
	cor.rgb = RGBtoHSV(cor.rgb);
	cor.r = (cor.r + timer / 10.) % 360.;
	cor.rgb = HSVtoRGB(cor.rgb);
	cor.r = trunc(cor.r * 7.+.5) / 7.; //normalize(cor.r * 255, 0, 255, 0, 8) / 8.;
	cor.g = trunc(cor.g * 7.+.5) / 7.; //normalize(cor.g * 255, 0, 255, 0, 8) / 8.;
	cor.b = trunc(cor.b * 3.+.5) / 3.; //normalize(cor.b * 255, 0, 255, 0, 3) / 3.;
	return cor;
}

float4 normalizePS(VertexShaderOutput input) : COLOR
{
	float4 cor = (tex2D(tex_samp, input.tex) + tex2D(tex_samp2, input.tex));
	cor.r = (cor.r - minv) * ((newMax - newMin) / (maxv - minv)) + newMin;
	cor.g = (cor.g - minv) * ((newMax - newMin) / (maxv - minv)) + newMin;
	cor.b = (cor.b - minv) * ((newMax - newMin) / (maxv - minv)) + newMin;
	return cor;
}
float4 truncatePS(VertexShaderOutput input) : COLOR
{
	float4 cor = (tex2D(tex_samp, input.tex) + tex2D(tex_samp2, input.tex));
	cor.r = max(newMin, min(cor.r, newMax));
	cor.g = max(newMin, min(cor.g, newMax));
	cor.b = max(newMin, min(cor.b, newMax));
	return cor;
}
float4 wrapPS(VertexShaderOutput input) : COLOR
{
	float4 cor = (tex2D(tex_samp, input.tex) + tex2D(tex_samp2, input.tex));
	cor.r = ((cor.r - newMin) % (newMax - newMin)) + newMin;
	cor.g = ((cor.g - newMin) % (newMax - newMin)) + newMin;
	cor.b = ((cor.b - newMin) % (newMax - newMin)) + newMin;
	return cor;
}

float4 hsv1(VertexShaderOutput input) : COLOR
{
	float4 cor = tex2D(tex_samp, input.tex);
	// to hsv
	float3 hsv = RGBtoHSV(cor.rgb);
	hsv.x /= 360.;
	return float4(hsv,1.);
}
float4 hsv2(VertexShaderOutput input) : COLOR
{
	float4 cor = tex2D(tex_samp, input.tex);
	// to hsv
	float3 hsv = RGBtoHSV(cor.rgb);
	hsv.x /= 360.;
	return float4(hsv.x, hsv.x, hsv.x, 1.);
}
float4 hsv3(VertexShaderOutput input) : COLOR
{
	float4 cor = tex2D(tex_samp, input.tex);
	// to hsv
	float3 hsv = RGBtoHSV(cor.rgb);
	return float4(hsv.y, hsv.y, hsv.y, 1.);
}
float4 hsv4(VertexShaderOutput input) : COLOR
{
	float4 cor = tex2D(tex_samp, input.tex);
	// to hsv
	float3 hsv = RGBtoHSV(cor.rgb);
	return float4(hsv.z, hsv.z, hsv.z, 1.);
}

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
technique Basic
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};
technique truncate
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL truncatePS();
	}
};
technique normalize
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL normalizePS();
	}
};
technique wrap
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL wrapPS();
	}
};
technique hsv
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL hueShiftPS();
	}
};

technique hsv1
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL hsv1();
	}
};
technique hsv2
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL hsv2();
	}
};
technique hsv3
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL hsv3();
	}
};
technique hsv4
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL hsv4();
	}
};
technique _8bits
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL _8bitsPS();
	}
};

technique _8bitsHue
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL _8bitsHuePS();
	}
};
