Texture2D blurTexture : register(t0); //texture that has gone through the blur shader stages
Texture2D renderTexture : register(t1); //original render texture
SamplerState SampleType : register(s0); 


cbuffer BloomBuffer : register(b0)
{
    float bloomIntensity; //variable for setting the intensity of the bloom 
    float3 padding;
};
struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
};

float4 main(InputType input) : SV_TARGET
{
    float4 colour;
    
    float4 blurColour = saturate(mul(blurTexture.SampleLevel(SampleType, input.tex, 0.0f), bloomIntensity)); //Sample the colour from the blur texture and multiply it by the intensity
    float4 sceneColour = renderTexture.SampleLevel(SampleType, input.tex, 0.0f); //Sample the colour from the original texture
    
    //Blend the two textures
    colour = saturate(blurColour + sceneColour);
    return colour;
}