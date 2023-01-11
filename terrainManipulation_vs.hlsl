Texture2D texture0 : register(t0); //Height map texture
SamplerState sampler0 : register(s0); //height map sampler

cbuffer MatrixBuffer : register(b0)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
    matrix lightViewMatrix[6];
    matrix lightProjectionMatrix[6];
};

cbuffer CameraBuffer : register(b1)
{
    float3 cameraPosition;
    float padding;
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
    
    float4 lightViewPos1 : TEXCOORD2;
    float4 lightViewPos2 : TEXCOORD3;
    float4 lightViewPos3 : TEXCOORD4;
    float4 lightViewPos4 : TEXCOORD5;
    float4 lightViewPos5 : TEXCOORD6;
    float4 lightViewPos6 : TEXCOORD7;
    
};

float getheight(float2 uv)
{
    
    float4 textureColour;
    float scale = 10.f; //Scale to change the terrain height
    textureColour = texture0.SampleLevel(sampler0, uv, 0).r * scale; //sample heightmap pixel colour and multiply by the scale 
    return textureColour;
}

float3 getNormal(float2 currentUV, float UVincrement, float4 currentPosition, float positionIncrement)
{
    float forwardHeight, downwardHeight, leftHeight, rightHeight;
    float3 normal1, normal2, normal3, normal4; //store cross product calculations in these vectors
    
    float3 U = float3(0.f,0.f,0.f); //initialese two vectors for cross product calculations
    float3 V = float3(0.f, 0.f, 0.f);
    
    //The code underneath solves the issue of coordinates that have no adjecent coordinates in a certain
    //direction by assuming that these coordinates would follow the same
    //direction between the coordinate opposite from it and the current coordinate
    //If the coordinate has all 4 adjacent coordinates around it, it gets the y-coordinate value 
    //By finding the next point through the use of UVIncrement. 
   
  
    if (currentUV.y < 0.0001f) //These numbers are decimal numbers to avoid floating point issues
    {
        forwardHeight = getheight(float2(currentUV.x, currentUV.y + UVincrement));                                  
    }
    else
    {
        forwardHeight = getheight(float2(currentUV.x, currentUV.y - UVincrement));
    }
    if (currentUV.y > 0.9999f)
    {
        downwardHeight = getheight(float2(currentUV.x, currentUV.y - UVincrement));
    }
    else
    {
        downwardHeight = getheight(float2(currentUV.x, currentUV.y + UVincrement));

    }
    if (currentUV.x < 0.0001f)
    {
        leftHeight = getheight(float2(currentUV.x - UVincrement, currentUV.y));
    }
    else
    {
        leftHeight = getheight(float2(currentUV.x + UVincrement, currentUV.y));
    }
    if (currentUV.x > 0.9999f)
    {
        rightHeight = getheight(float2(currentUV.x + UVincrement, currentUV.y));
    }
    else
    {
        rightHeight = getheight(float2(currentUV.x - UVincrement, currentUV.y));
    }
    
    
    //set each position around the current point through the use of knowing the distance between the current point and the next point (positionIncrement)
    float4 forwardPos = float4(currentPosition.x, forwardHeight, currentPosition.z - positionIncrement,1.0f);
    float4 backwardPos = float4(currentPosition.x, downwardHeight, currentPosition.z + positionIncrement,1.0f);
    float4 leftPos = float4(currentPosition.x - positionIncrement, leftHeight, currentPosition.z,1.0f);
    float4 rightPos = float4(currentPosition.x + positionIncrement, rightHeight, currentPosition.z,1.0f);
    float3 averageCrossProduct;
    
    
    //----Normal calculation using the cross products between the four triangles that can be created from the 4 adjecent coordinates of the current coordinate 
    //----Store the result of these calculations in a vector3 
    //Top cross product
    U.x = rightPos.x - currentPosition.x;
    U.y = rightPos.y - currentPosition.y;
    U.y = rightPos.z - currentPosition.z;
    
    V.x = forwardPos.x - currentPosition.x;
    V.y = forwardPos.y - currentPosition.y;
    V.z = forwardPos.z - currentPosition.z;
    
    normal1.x = mul(U.y, V.z) - mul(U.z, V.y);
    normal1.y = mul(U.z, V.x) - mul(U.x, V.z);
    normal1.z = mul(U.x, V.y) - mul(U.y, V.x);
    
    //Right Cross product
    U.x = backwardPos.x - currentPosition.x;
    U.y = backwardPos.y - currentPosition.y;
    U.z = backwardPos.z - currentPosition.z;
    
    V.x = rightPos.x - currentPosition.x;
    V.y = rightPos.y - currentPosition.y;
    V.z = rightPos.z - currentPosition.z;
    
    normal2.x = mul(U.y, V.z) - mul(U.z, V.y);
    normal2.y = mul(U.z, V.x) - mul(U.x, V.z);
    normal2.z = mul(U.x, V.y) - mul(U.y, V.x);
    
    //Bottom cross product
    U.x = leftPos.x - currentPosition.x;
    U.y = leftPos.y - currentPosition.y;
    U.z = leftPos.z - currentPosition.z;
    
    V.x = backwardPos.x - currentPosition.x;
    V.y = backwardPos.y - currentPosition.y;
    V.z = backwardPos.z - currentPosition.z;
    
    normal3.x = mul(U.y, V.z) - mul(U.z, V.y);
    normal3.y = mul(U.z, V.x) - mul(U.x, V.z);
    normal3.z = mul(U.x, V.y) - mul(U.y, V.x);
    
    //Left cross product
    U.x = forwardPos.x - currentPosition.x;
    U.y = forwardPos.y - currentPosition.y;
    U.z = forwardPos.z - currentPosition.z;
    
    V.x = leftPos.x - currentPosition.x;
    V.y = leftPos.y - currentPosition.y;
    V.z = leftPos.z - currentPosition.z;
    
    normal4.x = mul(U.y, V.z) - mul(U.z, V.y);
    normal4.y = mul(U.z, V.x) - mul(U.x, V.z);
    normal4.z = mul(U.x, V.y) - mul(U.y, V.x);
    
    //calculate the average between the 4 cross products to get the correct normal corresponding to the current coordinate
    averageCrossProduct.x = (normal1.x + normal2.x + normal3.x + normal4.x) / 4; 
    averageCrossProduct.y = (normal1.y + normal2.y + normal3.y + normal4.y) / 4;
    averageCrossProduct.z = (normal1.z + normal2.z + normal3.z + normal4.z) / 4;
 
    return averageCrossProduct;
}

OutputType main(InputType input)
{
    OutputType output;

    //use the getheight function to calculate the y-offset of the plane
    input.position.y += getheight(input.tex);
    
    //proper matrix calculations so that these points get correctly transformed into world space
    output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
   
	// Store the texture coordinates for the pixel shader.
    
    output.tex = input.tex;
   
	// Calculate the normal vectors and normalise.
    output.normal = mul(getNormal(input.tex, 0.01f, input.position, 1), (float3x3) worldMatrix);
    output.normal = normalize(output.normal);
    
    // calculate the worldposition
    output.worldPosition = mul(input.position, worldMatrix);
    
    //----Get the lightViewPositions by using their corresponding light matrices to calculate their position
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