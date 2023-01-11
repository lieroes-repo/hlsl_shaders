Texture2D shaderTexture : register(t0); //Rendertexture from the firstPass() function
SamplerState SampleType : register(s0); 

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
};

float4 main(InputType input) : SV_TARGET
{
    float4 colour;
    float brightness;
    float4 black = float4(0.0f, 0.0f, 0.0f, 1.0f);
   
    colour = shaderTexture.SampleLevel(SampleType, input.tex, 0.0f);
    
    //store the length of the colour vector (||a|| = root(a1^2 + a2^2 + a3^3))
    brightness = sqrt((pow(colour.x, 2) + pow(colour.y, 2) + pow(colour.z, 2)));
    
    //If the brightness of the pixel is smaller than the cutoff value, the pixel is rendered as black
    if (brightness < 0.75f)
    {
        return black;
    }
    else
    {
        //pixel colour is bright enough, so render pixel colour as normal
        return colour;
    }

}