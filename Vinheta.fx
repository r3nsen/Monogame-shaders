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
struct VertexShaderOutput
{
	float4 position : SV_POSITION;
	float4 color : COLOR0;
	float2 tex: TEXCOORD0;
};

float4 MainPS(VertexShaderOutput input) : COLOR
{	
	float2 uv = input.tex.xy;
	float pi = 3.141592653589793238462643383279;
	float darkness = (sin(uv.x * (pi / 3) + pi / 3) * sin(uv.y * (pi / 3) + pi / 3));

	float4 color = tex2D(texture_sampler,input.tex) * input.color * darkness;
	return color;
}

technique BasicColorDrawing
{
	pass P0
	{		
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};
