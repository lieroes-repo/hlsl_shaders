
Texture2D shaderTexture : register(t0); //Texture for object
Texture2D depthMapTexture0 : register(t1); //Depth Map texture for directional light
Texture2D depthMapTexture1 : register(t2); //** for SpotLight

SamplerState diffuseSampler : register(s0); //Sampler for light
SamplerState shadowSampler : register(s1); //Sampler for shadows

    cbuffer LightBuffer : register(b0)
    {
        float4 diffuse[6];
        float4 position[5];
        float4 ambient[2];
        float coneangle;
        float3 direction0;
        float3 direction1;
        float padding1;
        float4 strength[5];
    };

struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float3 worldPosition : TEXCOORD1;
    
    //Receive light data from vertex shader
    
    float4 lightViewPos6 : TEXCOORD2; 
    float4 lightViewPos5 : TEXCOORD3;
    
    
};
bool hasDepthData(float2 uv) //Check if the uv coordinates have depth data
{
    if (uv.x < 0.f || uv.x > 1.f || uv.y < 0.f || uv.y > 1.f)
    {
        return false;
    }
    return true;
}

bool isInShadow(Texture2D sMap, float2 uv, float4 lightViewPosition, float bias)
{
    // Sample the shadow map (get depth of geometry)
    float depthValue = sMap.Sample(shadowSampler, uv).r;
	// Calculate the depth from the light.
    float lightDepthValue = lightViewPosition.z / lightViewPosition.w;
    lightDepthValue -= bias;

	// Compare the depth of the shadow map value and the depth of the light to determine whether to shadow or to light this pixel.
    if (lightDepthValue < depthValue)
    {
        return false;
    }
    return true;
}

float2 getProjectiveCoords(float4 lightViewPosition)
{
    // Calculate the projected texture coordinates.
    float2 projTex = lightViewPosition.xy / lightViewPosition.w;
    projTex *= float2(0.5, -0.5);
    projTex += float2(0.5f, 0.5f);
    return projTex;
}

float4 calculatePointLight(float3 normal, float3 lightPosition, float4 diffuse, float3 worldPosition) //Function for calculating the point lights
{
    float intensity;
    float4 colour;
    float3 lightVector;
    lightVector = normalize(lightPosition - worldPosition);
    intensity = saturate(dot(normal, lightVector));
    colour = mul(diffuse, intensity);
    return colour;

}
float calculateSpotLight(float4 ambient, float4 diffuse, float3 lightPosition, float angle, float3 direction, float3 normal, float3 worldPosition)
{
    float intensity;
    float4 colour;
    float3 lightVector;
    lightVector = normalize(lightPosition - worldPosition);
    intensity = saturate(dot(normal, lightVector));
    colour = ambient + mul(diffuse, intensity);
    colour *= pow(max(dot(-lightVector, direction), 0.0f), coneangle);
    return colour;

}
float4 calculateDirectionalLight(float4 ambient, float4 diffuse, float3 normal, float3 direction)
{
    float intensity;
    float4 colour;
    intensity = saturate(dot(normal, -direction));
    colour = ambient + saturate(mul(diffuse, mul(intensity, 0.2f)));
    return colour;
}

float4 main(InputType input) : SV_TARGET
{
    float shadowMapBias = 0.005f;
    float4 shadowColour = float4(0.f, 0.f, 0.f, 1.f);
    float4 colour, colour1, colour2, colour3, colour4, colour5, colour6; 
    float4 textureColour = shaderTexture.Sample(diffuseSampler, input.tex);

	// Calculate the projected texture coordinates.
    float2 pTexCoord6 = getProjectiveCoords(input.lightViewPos6);
    float2 pTexCoord5 = getProjectiveCoords(input.lightViewPos5);
    
	//--------------Directional Light Shadow
    // Shadow test. Is or isn't in shadow
    if (hasDepthData(pTexCoord6))
    {
        // Has depth map data
        if (!isInShadow(depthMapTexture0, pTexCoord6, input.lightViewPos6, shadowMapBias))
        {
            // is NOT in shadow, therefore light
            colour6 = calculateDirectionalLight(ambient[1], diffuse[5], input.normal, direction1);
        }
        else //is in shadow
        {
            colour6 = shadowColour;
        }
    }
    
    
    //--------------Spotlight Shadow
    if (hasDepthData(pTexCoord5))
    {
        if (!isInShadow(depthMapTexture1, pTexCoord5, input.lightViewPos5, shadowMapBias))
        {
            colour5 = calculateSpotLight(ambient[0], diffuse[4], position[4].xyz, coneangle, direction0, input.normal, input.worldPosition);
        }
        else
        {
            colour5 = shadowColour;
        }
    }
     
    //point Lights
    colour1 = calculatePointLight(input.normal, position[0].xyz, diffuse[0], input.worldPosition);
    colour2 = calculatePointLight(input.normal, position[1].xyz, diffuse[1], input.worldPosition);
    colour3 = calculatePointLight(input.normal, position[2].xyz, diffuse[2], input.worldPosition);
    colour4 = calculatePointLight(input.normal, position[3].xyz, diffuse[3], input.worldPosition);
    
    colour = saturate(colour1 * strength[0].x + colour2 * strength[1].x + colour3 * strength[2].x + colour4 * strength[3].x + colour5 * strength[4].x + colour6) * textureColour;
    return colour;
}