// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "HeatDistortion" {
 
  Properties {
    _NoiseTex ("Noise Texture (RG)", 2D) = "white" {}
    strength("strength", Range(0.1, 0.3)) = 0.2
    transparency("transparency", Range(0.01, 0.1)) = 0.05
	_MaxDistortion ("Max Distortion Value", Float) = 0.3
  }
 
  Category {
    Tags { "Queue" = "Transparent+10" }
    SubShader {
   
      // http://docs.unity3d.com/Manual/SL-GrabPass.html
      // http://docs.unity3d.com/Manual/SL-PassTags.html
      GrabPass {
        Name "BASE"
        Tags { "LightMode" = "Always" } // no lighting
      }
   
      Pass {
        Name "BASE"
        Tags { "LightMode" = "Always" }
        Fog { Color (0,0,0,0) }
        Lighting Off
        Cull Off
        ZWrite On
        ZTest LEqual
        Blend SrcAlpha OneMinusSrcAlpha
        AlphaTest Greater 0
     
        CGPROGRAM
        // Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members distortion)
        //#pragma exclude_renderers d3d11 xbox360
        // Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members distortion)
       // #pragma exclude_renderers xbox360
        #pragma vertex vert
        #pragma fragment frag
       //#pragma fragmentoption ARB_precision_hint_fastest
       //#pragma fragmentoption ARB_fog_exp2
        #include "UnityCG.cginc"
     
        // http://forum.unity3d.com/threads/what-does-register-s0-do.26816/
        sampler2D _GrabTexture : register(s0);
        float4 _NoiseTex_ST;
        sampler2D _NoiseTex;
        float strength;
        float transparency;
		float _MaxDistortion;
     
		struct appdata_t
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
		};
     
        struct v2f 
		{
          float4 position : POSITION;
          float4 screenPos : TEXCOORD0;
          float2 uvmain : TEXCOORD2;
          float distortion : TEXCOORD3; //Needs semantic. Dx11 doesn't pass it.
        };
     
        v2f vert(appdata_t i)
		{
          v2f o;
          o.position = UnityObjectToClipPos(i.vertex);      // compute transformed vertex position
          o.uvmain = TRANSFORM_TEX(i.texcoord, _NoiseTex);   // compute the texcoords of the noise
          float viewAngle = dot(normalize(ObjSpaceViewDir(i.vertex)), i.normal);
          o.distortion = viewAngle * viewAngle; // square viewAngle to make the effect fall off stronger
          float depth = -mul( UNITY_MATRIX_MV, i.vertex ).z;  // compute vertex depth
          o.distortion /= 1 + depth;  // scale effect with vertex depth
		  o.distortion = clamp(o.distortion, 0, _MaxDistortion);
          o.distortion *= strength; // multiply with user controlled strength
          o.screenPos = o.position; // pass the position to the pixel shader
          return o;
        }
     
        half4 frag( v2f i ) : COLOR
        {
          // compute the texture coordinates
          float2 screenPos = i.screenPos.xy / i.screenPos.w;   // screenpos ranges from -1 to 1
          screenPos.x = (screenPos.x + 1) * 0.5;   // I need 0 to 1
          screenPos.y = (screenPos.y + 1) * 0.5;   // I need 0 to 1
       
          // check if anti aliasing is used
          //if (_ProjectionParams.x < 0) screenPos.y = 1 - screenPos.y;

		  //Comment this out if you're not using AA
          screenPos.y = 1 - screenPos.y;
       
          // get two offset values by looking up the noise texture shifted in different directions
          half4 offsetColor1 = tex2D(_NoiseTex, i.uvmain + _Time.xz);
          half4 offsetColor2 = tex2D(_NoiseTex, i.uvmain - _Time.yx);
       
          // use the r values from the noise texture lookups and combine them for x offset
          // use the g values from the noise texture lookups and combine them for y offset
          // use minus one to shift the texture back to the center
          // scale with distortion amount
          screenPos.x += ((offsetColor1.r + offsetColor2.r) - 1) * i.distortion;
          screenPos.y += ((offsetColor1.g + offsetColor2.g) - 1) * i.distortion;
          half4 col = tex2D( _GrabTexture, screenPos );
          col.a = i.distortion / transparency;
          return col;
        }
     
        ENDCG
      }
    }
  }
}