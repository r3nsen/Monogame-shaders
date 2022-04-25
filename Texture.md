## compila para opengl ou para directx
```hlsl
#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0
	#define PS_SHADERMODEL ps_4_0
#endif
```

## usar textura
```hlsl
Texture2D tex;
sampler2D texture_sampler = sampler_state
{
	Texture = <tex>;
};
```

## structs com propriedades
```hlsl
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
```

## vertex shader
```hlsl
VertexShaderOutput MainVS(in VertexShaderInput input)
{
	VertexShaderOutputT output = (VertexShaderOutput)0;
  
	output.position = mul(input.position, WorldViewProjection);
	output.color = input.color;
	output.tex = input.tex;
  
	return output;
}
```

## pixel shader / fragment shader
```hlsl
float4 MainPS(VertexShaderOutput input) : COLOR
{			
	return tex2D(texture_sampler, input.tex) * input.Color;
}
```

## definir técnica e passos
```hlsl
technique BasicColorDrawing
{
	pass P0
	{		
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};
```

## código final
```hlsl
#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0
	#define PS_SHADERMODEL ps_4_0
#endif

Texture2D tex;
sampler2D texture_sampler = sampler_state
{
	Texture = <tex>;
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

VertexShaderOutput MainVS(in VertexShaderInput input)
{
	VertexShaderOutputT output = (VertexShaderOutput)0;
  
	output.position = mul(input.position, WorldViewProjection);
	output.color = input.color;
	output.tex = input.tex;
  
	return output;
}

float4 MainPS(VertexShaderOutput input) : COLOR
{			
	return tex2D(texture_sampler, input.tex) * input.Color;
}

technique BasicColorDrawing
{
	pass P0
	{		
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};
```
