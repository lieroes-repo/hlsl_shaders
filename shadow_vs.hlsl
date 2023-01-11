
cbuffer MatrixBuffer : register(b0)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
    matrix lightViewMatrix[6];
    matrix lightProjectionMatrix[6];
};

struct InputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
};

struct OutputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float3 worldPosition : TEXCOORD1;
    
    float4 lightViewPos6 : TEXCOORD2;
    float4 lightViewPos5 : TEXCOORD3;
    

};

OutputType main(InputType input)
{
    OutputType output;


	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
    
    output.tex = input.tex;
    output.normal = mul(input.normal, (float3x3) worldMatrix);
    output.normal = normalize(output.normal);
    
    output.worldPosition = mul(input.position, worldMatrix);
	// Calculate the position of the vertice as viewed by the light source.
    
    //directional light
    output.lightViewPos6 = mul(input.position, worldMatrix);
    output.lightViewPos6 = mul(output.lightViewPos6, lightViewMatrix[5]);
    output.lightViewPos6 = mul(output.lightViewPos6, lightProjectionMatrix[5]);
    
    //spotLight
    output.lightViewPos5 = mul(input.position, worldMatrix);
    output.lightViewPos5 = mul(output.lightViewPos5, lightViewMatrix[4]);
    output.lightViewPos5 = mul(output.lightViewPos5, lightProjectionMatrix[4]);

   

    return output;
}