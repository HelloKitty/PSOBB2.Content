Shader "Custom/RockWithLavaFlow" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_CutOff ("Cutoff Value", Range(0,1)) = 0.0
		_CutOffTex ("Cutoff Texture", 2D) = "white" {}

		_EmissionTex ("Emission Texture", 2D) = "white" {}

		_EmissionLM ("Emission (Lightmapper)", Float) = 0
		[Toggle] _DynamicEmissionLM ("Dynamic Emission (Lightmapper)", Int) = 0

		_DistortMap ("Distortion Map", 2D) = "white" {}
		_DistortMultiplier ("Distortion Multiplier", Float) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		//Blend SrcAlpha One
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _CutOffTex;
		sampler2D _EmissionTex;
		sampler2D _BumpMap;
		sampler2D _DistortMap;
		half _CutOff;

		struct Input {
			float2 uv_MainTex;
			float2 uv_EmissionTex;
			float2 uv_CutOffTex;
			float2 uv_DistortMap;
		};

		half _Glossiness;
		half _Metallic;
		half _EmissionLM;
		half _DistortMultiplier;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed cutoffTexAlpha = tex2D (_CutOffTex, IN.uv_CutOffTex).a;

			o.Albedo = c;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;

			//TODO: Rewrite without an if
			if(cutoffTexAlpha - _CutOff < 0)
			{
				fixed4 emC = tex2D(_EmissionTex, IN.uv_EmissionTex + UnpackNormal(tex2D(_DistortMap, IN.uv_DistortMap)) * _DistortMultiplier);
				o.Albedo = emC;
				o.Emission = o.Albedo * _EmissionLM;//clamp(0, 1, o.Albedo * _EmissionLM) * emC.a;
			}

			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
			//clip(cutoffTexAlpha - _CutOff);
		}
		ENDCG
	} 
	Fallback "Diffuse"
}
