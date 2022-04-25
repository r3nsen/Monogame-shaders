#if OPENGL
	#define SV_POSITION POSITION
	#define VS_SHADERMODEL vs_3_0
	#define PS_SHADERMODEL ps_3_0
#else
	#define VS_SHADERMODEL vs_4_0
	#define PS_SHADERMODEL ps_4_0
#endif

matrix WorldViewProjection;

float volume[3]; // numero de arquivos (3) hardcoded
float currentVolume;
int sampleRate;
int volumeDelay = 1000;

#define filterLen 51
float filter[filterLen];

int gridX = 1; 
int gridY = 3;
int width = 2400;// (60 * 40) //60;
int height = 1;//40;

Texture2D tex;
sampler2D texture_sampler = sampler_state
{
	Texture = <tex>;
};

struct VertexShaderInput
{
	float4 pos : POSITION0;
	float4 color : COLOR0;
	float2 tex : TEXCOORD0;
};
struct VertexShaderOutput
{
	float4 pos : SV_POSITION;
	float4 color : COLOR0;
	float2 tex : TEXCOORD0;
};

VertexShaderOutput MainVS(in VertexShaderInput input)
{
	VertexShaderOutput output = (VertexShaderOutput)0;

	output.pos = mul(input.pos, WorldViewProjection);
	output.color = input.color;
	output.tex = input.tex;

	return output;
}
float4 MainPS(VertexShaderOutput input) : COLOR{
	return tex2D(texture_sampler, input.tex) * input.Color;
}
VertexShaderOutput AudioVS(in VertexShaderInput input)
{
	VertexShaderOutput output = (VertexShaderOutput)0;

	output.pos = mul(input.pos, WorldViewProjection);
	output.color = input.color;
	output.tex = input.tex;

	return output;
}

int2 getPCMData(float4 sample)
{
	int2 output;
	int inLChannel = float((int(ceil(sample.r * 255.0))) | ((int(ceil(sample.g * 255.0))) << 8));
	int inRChannel = float((int(ceil(sample.b * 255.0))) | ((int(ceil(sample.a * 255.0))) << 8));

	if (inLChannel >> 15) inLChannel |= 0xffff0000;
	if (inRChannel >> 15) inRChannel |= 0xffff0000;

	return int2(inLChannel, inRChannel);
}

int2 getSample(float2 pos, int index)
{
	float4 sample = tex2D(texture_sampler, float2(pos.x / gridX, (pos.y / gridY) + (float(index) / gridY)));
	return getPCMData(sample);
}
// necessita de revisão, samples passados via textura possuem artefatos por falta de continuidade
int2 passFilter(float2 pos, int index)
{
	int2 channels = getSample(pos, index) * filter[0];
	return channels;//
	float passoX = 1.0 / width;
	float passoY = 1.0 / height;

	float leftLimit = 0.0;
	float rightLimit = 1.0;
	float topLimit = 0.0;
	float bottomLimit = 1.0;

	for (int i = 1; i < filterLen; i++)
	{
		float2 pPos = float2(pos.x + passoX * i, pos.y);
		while (pPos.x > rightLimit)
		{
			pPos.y += passoY;
			pPos.x -= 1.0;
		}
		float2 nPos = float2(pos.x - passoX * i, pos.y);
		while (nPos.x < leftLimit)
		{
			nPos.y -= passoY;
			nPos.x += 1.0;
		}

		channels += getSample(pPos, index) * filter[i] * (pPos.y <= bottomLimit);
		channels += getSample(nPos, index) * filter[i] * (nPos.y >= topLimit);
	}
	return channels;
}

float4 AudioPS(VertexShaderOutput input) : COLOR
{
	int2 outChannels = 0;
	float2 pos = input.tex;
	for (int i = 0; i < 3; i++)
	{
		int2 channels = getSample(pos, i);
		channels = passFilter(pos, i);
		channels *= volume[i];

		outChannels += channels;
	}

	float4 sample = float4((outChannels.x & 0x00ff) / 255.0, ((outChannels.x >> 8) & 0xff) / 255.0,
	                       (outChannels.y & 0x00ff) / 255.0, ((outChannels.y >> 8) & 0xff) / 255.0);

	return sample;
}

technique BasicColorDrawing
{
	pass P0
	{
		VertexShader = compile VS_SHADERMODEL AudioVS();
		PixelShader = compile PS_SHADERMODEL AudioPS();
	}

	pass P1
	{
		VertexShader = compile VS_SHADERMODEL MainVS();
		PixelShader = compile PS_SHADERMODEL MainPS();
	}
};
