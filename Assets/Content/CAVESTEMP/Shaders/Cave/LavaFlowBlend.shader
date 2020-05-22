Shader "Custom/LavaFlowBlendBlend" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DistortMap ("Distortion Map", 2D) = "white" {}
		_DistortMultiplier ("Distortion Multiplier", Float) = 1.0
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_BlendTex ("Texture to Blend to", 2D) = "white" {}
		_WorldYBlendPoint ("Y-Coord for Blend", Float) = 0.0
		_BlendSize ("Blending Size", Float) = 1.0

		_EmissionLM ("Emission (Lightmapper)", Float) = 0
		[Toggle] _DynamicEmissionLM ("Dynamic Emission (Lightmapper)", Int) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _DistortMap;
		sampler2D _BlendTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_DistortMap;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		half _EmissionLM;
		half _DistortMultiplier;
		half _WorldYBlendPoint;
		half _BlendSize;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			IN.uv_MainTex = IN.uv_MainTex + UnpackNormal(tex2D(_DistortMap, IN.uv_DistortMap)) * _DistortMultiplier;

			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			float yDelta = IN.worldPos.y - _WorldYBlendPoint;
			o.Albedo = lerp(tex2D(_BlendTex, IN.uv_MainTex) , c, clamp(yDelta * yDelta / _BlendSize, 0, 1));
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Emission = _EmissionLM * o.Albedo;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
