//////////////////////////////////////////////////////////////
/// Shadero Sprite: Sprite Shader Editor - by VETASOFT 2018 //
/// Shader generate with Shadero 1.9.6                      //
/// http://u3d.as/V7t #AssetStore                           //
/// http://www.shadero.com #Docs                            //
//////////////////////////////////////////////////////////////

Shader "Shadero Customs/Title"
{
Properties
{
[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
_NewTex_1("NewTex_1(RGB)", 2D) = "white" { }
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
sampler2D _NewTex_1;

v2f vert(appdata_t IN)
{
v2f OUT;
OUT.vertex = UnityObjectToClipPos(IN.vertex);
OUT.texcoord = IN.texcoord;
OUT.color = IN.color;
return OUT;
}


float2 SlicedVerticalBarUV(float2 uv, float b1, float s)
{
float ov = uv.y;
float muv =uv.y;
muv *= s;
float s1 = muv;
float s2 = 1+muv-s;
float z = b1 / s;
muv = lerp(b1, 1. - b1, ov);
muv -= z;
uv.y = muv / (1. - (z * 2.));
if (ov < z) { uv.y = s1; }
if (ov > 1. - z) { uv.y = s2; }
return uv;
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
float3 Generate_Voronoi_hash3(float2 p, float seed)
{
float3 q = float3(dot(p, float2(127.1, 311.7)),
dot(p, float2(269.5, 183.3)),
dot(p, float2(419.2, 371.9)));
return frac(sin(q) * 43758.5453 * seed);
}
float4 Generate_Voronoi(float2 uv, float size,float seed, float black)
{
float2 p = floor(uv*size);
float2 f = frac(uv*size);
float k = 1.0 + 63.0*pow(1.0, 4.0);
float va = 0.0;
float wt = 0.0;
for (int j = -2; j <= 2; j++)
{
for (int i = -2; i <= 2; i++)
{
float2 g = float2(float(i), float(j));
float3 o = Generate_Voronoi_hash3(p + g, seed)*float3(1.0, 1.0, 1.0);
float2 r = g - f + o.xy;
float d = dot(r, r);
float ww = pow(1.0 - smoothstep(0.0, 1.414, sqrt(d)), k);
va += o.z*ww;
wt += ww;
}
}
float4 result = saturate(va / wt);
result.a = saturate(result.a + black);
return result;
}
float2 AnimatedMouvementUV(float2 uv, float offsetx, float offsety, float speed)
{
speed *=_Time*50;
uv += float2(offsetx, offsety)*speed;
uv = fmod(uv,1);
return uv;
}
float2 ResizeUV(float2 uv, float offsetx, float offsety, float zoomx, float zoomy)
{
uv += float2(offsetx, offsety);
uv = fmod(uv * float2(zoomx*zoomx, zoomy*zoomy), 1);
return uv;
}

float2 ResizeUVClamp(float2 uv, float offsetx, float offsety, float zoomx, float zoomy)
{
uv += float2(offsetx, offsety);
uv = fmod(clamp(uv * float2(zoomx*zoomx, zoomy*zoomy), 0.0001, 0.9999), 1);
return uv;
}
float4 ColorTurnMetal(float2 uv, sampler2D txt, float speed)
{
float4 txt1=tex2D(txt,uv);
float lum = dot(txt1.rgb, float3 (0.4126, 0.8152, 0.1722));
float3 metal = float3(lum,lum,lum);
metal.r = lum * pow(0.66*lum, 4.0);
metal.g = lum * pow(0.66*lum, 4.0);
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
sortie.rgb=0.05+sortie.rgb*0.5+dot(sortie.rgb, float3 (0.2126, 0.2152, 0.1722))*0.5;
sortie.a=txt1.a;
return sortie; 
}
float2 AnimatedZoomUV(float2 uv, float zoom, float posx, float posy, float radius, float speed)
{
float2 center = float2(posx, posy);
uv -= center;
zoom -= radius * 0.1;
zoom += sin(_Time * speed * 20) * 0.1 * radius;
uv = uv * zoom;
uv += center;
return uv;
}
float2 AnimatedRotationUV(float2 uv, float rot, float posx, float posy, float radius, float speed)
{
uv = uv - float2(posx, posy);
float angle = rot * 0.01744444;
angle += sin(_Time * speed * 20) * radius;
float sinX = sin(angle);
float cosX = cos(angle);
float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
uv = mul(uv, rotationMatrix) + float2(posx, posy);
return uv;
}
float2 AnimatedShakeUV(float2 uv, float offsetx, float offsety, float zoomx, float zoomy, float speed)
{
float time = sin(_Time * speed * 5000 * zoomx);
float time2 = sin(_Time * speed * 5000 * zoomy);
uv += float2(offsetx * time, offsety * time2);
return uv;
}
float4 frag (v2f i) : COLOR
{
float4 _MainTex_1 = tex2D(_MainTex, i.texcoord);
float2 AnimatedRotationUV_1 = AnimatedRotationUV(i.texcoord,360,0.5,0.9,0.186,1.571);
float2 SlicedVerticalBarUV_1 = SlicedVerticalBarUV(AnimatedRotationUV_1,0.15,5.033);
float2 ResizeUV_1 = ResizeUV(SlicedVerticalBarUV_1,0,-0.406,1,1);
float4 NewTex_1 = tex2D(_NewTex_1,ResizeUV_1);
_MainTex_1 = lerp(_MainTex_1,_MainTex_1*_MainTex_1.a + NewTex_1*NewTex_1.a,0.368 * _MainTex_1.a);
float2 AnimatedZoomUV_1 = AnimatedZoomUV(i.texcoord,1,0.5,0.5,0.01,10);
float4 _MainTex_2 = tex2D(_MainTex,AnimatedZoomUV_1);
float2 AnimatedShakeUV_1 = AnimatedShakeUV(i.texcoord,0,0,1.45,1,0.725);
float2 AnimatedMouvementUV_1 = AnimatedMouvementUV(AnimatedShakeUV_1,-0.321,0.159,0.021);
float4 _Generate_Voronoi_1 = Generate_Voronoi(AnimatedMouvementUV_1,6.629,2,0);
float4 _TurnMetal_1 = ColorTurnMetal(i.texcoord,_MainTex,3.971);
float4 OperationBlend_1 = OperationBlend(_Generate_Voronoi_1, _TurnMetal_1, 0.343); 
_MainTex_2 = lerp(_MainTex_2,_MainTex_2*_MainTex_2.a + OperationBlend_1*OperationBlend_1.a,1.957 * _MainTex_2.a);
float4 OperationBlend_2 = OperationBlend(_MainTex_1, _MainTex_2, 0.431); 
float4 FinalResult = OperationBlend_2;
FinalResult.rgb *= i.color.rgb;
FinalResult.a = FinalResult.a * _SpriteFade * i.color.a;
return FinalResult;
}

ENDCG
}
}
Fallback "Sprites/Default"
}
