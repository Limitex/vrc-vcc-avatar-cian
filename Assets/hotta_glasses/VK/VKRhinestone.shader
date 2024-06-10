//Made by VoxelKei
//Copyright © 2019 VoxelKei All rights reserved.

Shader "VK/VKRhinestone" {
	Properties {
		_RefractFakeMap("RefractFakeMap", 2D) = "black" {}
		_RefractBright("RefractBright", Float) = 0.3
		_RefractColor("RefractColor", Color) = (1,1,1,1)

		_ReflectColor ("ReflectColor", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.98
		_Metallic ("Metallic", Range(0,1)) = 0.95
	}
	SubShader {
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma only_renderers d3d9 d3d11 
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float3 worldRefl;
			INTERNAL_DATA
		};

		sampler2D _RefractFakeMap;
		half _RefractBright;

		UNITY_INSTANCING_BUFFER_START(PropsRefract)
			UNITY_DEFINE_INSTANCED_PROP(fixed4, _RefractColor)
		UNITY_INSTANCING_BUFFER_END(PropsRefract)

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 worldReflection = normalize( i.worldRefl );
			o.Emission = ( UNITY_ACCESS_INSTANCED_PROP(PropsRefract, _RefractColor) * ( tex2D( _RefractFakeMap, worldReflection.xy ) * _RefractBright ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG


		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		Blend One One

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
		#pragma only_renderers d3d9 d3d11 

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;

		UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_DEFINE_INSTANCED_PROP(fixed4, _ReflectColor)
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = UNITY_ACCESS_INSTANCED_PROP(Props, _ReflectColor);
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
