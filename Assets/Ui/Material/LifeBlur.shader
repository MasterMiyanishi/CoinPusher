//////////////////////////////////////////////////////////////
/// Shadero Sprite: Sprite Shader Editor - by VETASOFT 2018 //
/// Shader generate with Shadero 1.9.6                      //
/// http://u3d.as/V7t #AssetStore                           //
/// http://www.shadero.com #Docs                            //
//////////////////////////////////////////////////////////////

Shader "Shadero Customs/LifeBlur"
{
Properties
{
[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
_SpriteFade("SpriteFade", Range(0, 1)) = 1.0

// required for UI.Mask
[HideInInspector]_StencilComp("Stencil Comparison", Float) = 8
[HideInInspector]_Stencil("Stencil ID", Float) = 0
[HideInInspector]_StencilOp("Stencil Operation", Float) = 0
[HideInInspector]_StencilWriteMask("Stencil Write Mask", Float) = 255
[HideInInspector]_StencilReadMask("Stencil Read Mask", Float) = 255
[HideInInspector]_ColorMask("Color Mask", Float) = 15

}

SubShader
{

Tags {"Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType" = "Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }
ZWrite Off Blend SrcAlpha OneMinusSrcAlpha Cull Off 

// required for UI.Mask
Stencil
{
Ref [_Stencil]
Comp [_StencilComp]
Pass [_StencilOp]
ReadMask [_StencilReadMask]
WriteMask [_StencilWriteMask]
}

Pass
{

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#include "UnityCG.cginc"

struct appdata_t{
float4 vertex   : POSITION;
float4 color    : COLOR;
float2 texcoord : TEXCOORD0;
};

struct v2f
{
float2 texcoord  : TEXCOORD0;
float4 vertex   : SV_POSITION;
float4 color    : COLOR;
};

sampler2D _MainTex;
float _SpriteFade;

v2f vert(appdata_t IN)
{
v2f OUT;
OUT.vertex = UnityObjectToClipPos(IN.vertex);
OUT.texcoord = IN.texcoord;
OUT.color = IN.color;
return OUT;
}


float CMPFXrng2(float2 seed)
{
return frac(sin(dot(seed * floor(50 + (_Time + 0.1) * 12.), float2(127.1, 311.7))) * 43758.5453123);
}

float CMPFXrng(float seed)
{
return CMPFXrng2(float2(seed, 1.0));
}

float4 CompressionFX(float2 uv, sampler2D source,float Value)
{
float2 blockS = floor(uv * float2(24., 19.))*4.0;
float2 blockL = floor(uv * float2(38., 14.))*4.0;
float r = CMPFXrng2(uv);
float lineNoise = pow(CMPFXrng2(blockS), 3.0) *Value* pow(CMPFXrng2(blockL), 3.0);
float4 col1 = tex2D(source, uv + float2(lineNoise * 0.02 * CMPFXrng(2.0), 0));
float4 result = float4(float3(col1.x, col1.y, col1.z), 1.0);
result.a = col1.a;
return result;
}
inline float Holo1mod(float x,float modu)
{
return x - floor(x * (1.0 / modu)) * modu;
}

inline float Holo1noise(sampler2D source,float2 p)
{
float _TimeX = _Time.y;
float sample = tex2D(source,float2(.2,0.2*cos(_TimeX))*_TimeX*8. + p*1.).x;
sample *= sample;
return sample;
}

inline float Holo1onOff(float a, float b, float c)
{
float _TimeX = _Time.y;
return step(c, sin(_TimeX + a*cos(_TimeX*b)));
}

float4 Hologram(float2 uv, sampler2D source, float value, float speed)
{
float alpha = tex2D(source, uv).a;
float _TimeX = _Time.y * speed;
float2 look = uv;
float window = 1. / (1. + 20.*(look.y - Holo1mod(_TimeX / 4., 1.))*(look.y - Holo1mod(_TimeX / 4., 1.)));
look.x = look.x + sin(look.y*30. + _TimeX) / (50.*value)*Holo1onOff(4., 4., .3)*(1. + cos(_TimeX*80.))*window;
float vShift = .4*Holo1onOff(2., 3., .9)*(sin(_TimeX)*sin(_TimeX*20.) + (0.5 + 0.1*sin(_TimeX*20.)*cos(_TimeX)));
look.y = Holo1mod(look.y + vShift, 1.);
float4 video = float4(0, 0, 0, 0);
float4 videox = tex2D(source, look);
video.r = tex2D(source, look - float2(.05, 0.)*Holo1onOff(2., 1.5, .9)).r;
video.g = videox.g;
video.b = tex2D(source, look + float2(.05, 0.)*Holo1onOff(2., 1.5, .9)).b;
video.a = videox.a;
video = video;
float vigAmt = 3. + .3*sin(_TimeX + 5.*cos(_TimeX*5.));
float vignette = (1. - vigAmt*(uv.y - .5)*(uv.y - .5))*(1. - vigAmt*(uv.x - .5)*(uv.x - .5));
float noi = Holo1noise(source,uv*float2(0.5, 1.) + float2(6., 3.))*value * 3;
float y = Holo1mod(uv.y*4. + _TimeX / 2. + sin(_TimeX + sin(_TimeX*0.63)), 1.);
float start = .5;
float end = .6;
float inside = step(start, y) - step(end, y);
float fact = (y - start) / (end - start)*inside;
float f1 = (1. - fact) * inside;
video += f1*noi;
video += Holo1noise(source,uv*2.) / 2.;
video.r *= vignette;
video *= (12. + Holo1mod(uv.y*30. + _TimeX, 1.)) / 13.;
video.a = video.a + (frac(sin(dot(uv.xy*_TimeX, float2(12.9898, 78.233))) * 43758.5453))*.5;
video.a = (video.a*.3)*alpha*vignette * 2;
video.a *=1.2;
video.a *= 1.2;
video = lerp(tex2D(source, uv), video, value);
return video;
}
float4 TintRGBA(float4 txt, float4 color)
{
float3 tint = dot(txt.rgb, float3(.222, .707, .071));
tint.rgb *= color.rgb;
txt.rgb = lerp(txt.rgb,tint.rgb,color.a);
return txt;
}
float4 Four_Gradients(float4 txt, float2 uv, float4 col1, float4 col2, float4 col3, float4 col4)
{
float4 colorA = lerp(col3,col4, uv.x*1.1);
float4 colorB = lerp(col1,col2, uv.x*1.1);
float4 colorC = lerp(colorA,colorB, uv.y*1.1);
colorA = lerp(txt, colorC, colorC.a);
colorA.a = txt.a;
return colorA;
}
float4 OperationBlend(float4 origin, float4 overlay, float blend)
{
float4 o = origin; 
o.a = overlay.a + origin.a * (1 - overlay.a);
o.rgb = (overlay.rgb * overlay.a + origin.rgb * origin.a * (1 - overlay.a)) * (o.a+0.0000001);
o.a = saturate(o.a);
o = lerp(origin, o, blend);
return o;
}
float4 ColorTurnGold(float2 uv, sampler2D txt, float speed)
{
float4 txt1=tex2D(txt,uv);
float lum = dot(txt1.rgb, float3 (0.2126, 0.2152, 0.4722));
float3 metal = float3(lum,lum,lum);
metal.r = lum * pow(1.46*lum, 4.0);
metal.g = lum * pow(1.46*lum, 4.0);
metal.b = lum * pow(0.86*lum, 4.0);
float2 tuv = uv;
uv *= 2.5;
float time = (_Time/4)*speed;
float a = time * 50;
float n = sin(a + 2.0 * uv.x) + sin(a - 2.0 * uv.x) + sin(a + 2.0 * uv.y) + sin(a + 5.0 * uv.y);
n = fmod(((5.0 + n) / 5.0), 1.0);
n += tex2D(txt, tuv).r * 0.21 + tex2D(txt, tuv).g * 0.4 + tex2D(txt, tuv).b * 0.2;
n=fmod(n,1.0);
float tx = n * 6.0;
float r = clamp(tx - 2.0, 0.0, 1.0) + clamp(2.0 - tx, 0.0, 1.0);
float4 sortie=float4(1.0, 1.0, 1.0,r);
sortie.rgb=metal.rgb+(1-sortie.a);
sortie.rgb=sortie.rgb/2+dot(sortie.rgb, float3 (0.1126, 0.4552, 0.1722));
sortie.rgb-=float3(0.0,0.1,0.45);
sortie.rg+=0.025;
sortie.a=txt1.a;
return sortie; 
}
float4 frag (v2f i) : COLOR
{
float4 _TurnGold_1 = ColorTurnGold(i.texcoord,_MainTex,8);
float4 TintRGBA_1 = TintRGBA(_TurnGold_1, float4(1,0,0,1));
float4 _Hologram_1 = Hologram(i.texcoord,_MainTex,1,0.479);
float4 _CompressionFX_1 = CompressionFX(i.texcoord,_MainTex,6.486);
float4 OperationBlend_2 = OperationBlend(_Hologram_1, _CompressionFX_1, 0.82); 
TintRGBA_1 = lerp(TintRGBA_1,TintRGBA_1*TintRGBA_1.a + OperationBlend_2*OperationBlend_2.a,1.889 * OperationBlend_2.a);
float4 _MainTex_1 = tex2D(_MainTex, i.texcoord);
float4 _FourGradients_1 = Four_Gradients(_MainTex_1,i.texcoord,float4(1,1,0,1),float4(1,1,0.3726415,1),float4(0.3113208,0.3113208,0.2540495,1),float4(0.6037736,0.6037736,0,1));
float4 OperationBlend_1 = OperationBlend(TintRGBA_1, _FourGradients_1, 0.834); 
float4 FinalResult = OperationBlend_1;
FinalResult.rgb *= i.color.rgb;
FinalResult.a = FinalResult.a * _SpriteFade * i.color.a;
return FinalResult;
}

ENDCG
}
}
Fallback "Sprites/Default"
}
