Shader "Custom/VolumetricLights" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_ColorBlend ("Blend To", Color) = (1,1,1,1)

		_WorldYBlendPoint ("Y-Coord for Blend", Float) = 0.0
		_BlendSize ("Blending Size", Float) = 1.0
		_BlendRate ("Blend Rate", Float) = 1.0
		_AlphaBlendRate ("Alpha Blend Rate", Float) = 1.0
		_EmissionBlendRate ("Emission Blend Rate", Float) = 1.0

		_EmissionLM ("Emission (Lightmapper)", Float) = 0
		[Toggle] _DynamicEmissionLM ("Dynamic Emission (Lightmapper)", Int) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard alpha:fade

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _EmissionLM;
		fixed4 _Color;
		half _WorldYBlendPoint;
		half _BlendSize;
		half _BlendRate;
		half _EmissionBlendRate;
		half _AlphaBlendRate;
		fixed4 _ColorBlend;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			float yDelta = IN.worldPos.y - _WorldYBlendPoint;
			o.Albedo = lerp(_Color, _ColorBlend, clamp(pow(yDelta, _BlendRate) / _BlendSize, 0, 1));

			//o.Emission = o.Albedo * _EmissionLM * abs(clamp(pow(yDelta, _EmissionBlendRate) / _BlendSize, 0, 1) - 1);
			o.Alpha = abs(clamp(pow(yDelta, _AlphaBlendRate) / _BlendSize, 0, 1) - 1);
			o.Emission = o.Albedo * _EmissionLM;
		}
		ENDCG
	} 
	FallBack "VertexLit"
}
