// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Irua/Particle_MeshDistortion"
{
	Properties
	{
		_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 1
		_DistortionStranth("Distortion Stranth", Range( 0 , 1)) = 1
		[Header(Fresnel Setting)]_FresnelPower("Fresnel Power", Range( 0 , 10)) = 0
		[HDR]_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		[Toggle]_DistortionToggle("DistortionToggle", Float) = 1
		[IntRange][Enum(Off,0,Front,1,Back,2)]_CullMode("CullMode", Float) = 0
		[Header(NormalFlow X Start Y End)]_NormalScaleFlow("NormalScaleFlow", Vector) = (0.5,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+1" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull [_CullMode]
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		BlendOp Max
		GrabPass{ "_ParticleDistorionMesh" }
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 4.5
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float3 worldPos;
			half ASEIsFrontFacing : VFACE;
			float3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
			float4 screenPos;
			float3 viewDir;
			float4 uv_texcoord;
		};

		uniform float _CullMode;
		uniform float _VRChatMirrorMode;
		uniform float _DistortionToggle;
		uniform float4 _FresnelColor;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _ParticleDistorionMesh )
		uniform sampler2D _Normal;
		uniform float2 _NormalScaleFlow;
		uniform float _NormalScale;
		uniform float _DistortionStranth;
		uniform float _FresnelPower;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float4 color152 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float4 temp_cast_0 = (color152.a).xxxx;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 temp_output_169_0 = ( ase_worldViewDir * (i.ASEIsFrontFacing > 0 ? +1 : -1 ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float fresnelNdotV130 = dot( ase_normWorldNormal, temp_output_169_0 );
			float fresnelNode130 = ( 0.0 + 1.0 * pow( max( 1.0 - fresnelNdotV130 , 0.0001 ), 8.0 ) );
			float4 temp_output_133_0 = ( fresnelNode130 * i.vertexColor * i.vertexColor.a * _FresnelColor );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float lerpResult200 = lerp( _NormalScaleFlow.x , _NormalScaleFlow.y , i.uv_texcoord.z);
			float2 appendResult198 = (float2(lerpResult200 , lerpResult200));
			float fresnelNdotV66 = dot( ase_worldNormal, temp_output_169_0 );
			float fresnelNode66 = ( 0.0 + _DistortionStranth * pow( 1.0 - fresnelNdotV66, _FresnelPower ) );
			float4 screenColor28 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_ParticleDistorionMesh,( ase_grabScreenPosNorm + float4( ( ( UnpackScaleNormal( tex2D( _Normal, ( ( (i.viewDir).xy * appendResult198 ) + float2( 0.5,0.5 ) ) ), _NormalScale ) + fresnelNode66 ) * i.vertexColor.a ) , 0.0 ) ).xy);
			float4 temp_cast_3 = (color152.a).xxxx;
			float4 ifLocalVar157 = 0;
			if( _VRChatMirrorMode == 0.0 )
				ifLocalVar157 = (( _DistortionToggle )?( ( screenColor28 + temp_output_133_0 ) ):( temp_output_133_0 ));
			else
				ifLocalVar157 = temp_cast_0;
			o.Emission = ifLocalVar157.rgb;
			float ifLocalVar160 = 0;
			if( _VRChatMirrorMode == 0.0 )
				ifLocalVar160 = (( _DistortionToggle )?( ( screenColor28 + temp_output_133_0 ) ):( temp_output_133_0 )).a;
			else
				ifLocalVar160 = color152.a;
			o.Alpha = ifLocalVar160;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;141;-503.7323,-982.4518;Inherit;False;636.6695;586.7433;RimLight;3;130;133;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;140;-790.4283,-1449.682;Inherit;False;923.4322;402.3455;GrabPass;4;26;109;105;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;139;-2187.349,-1393.107;Inherit;False;1250.943;759.3826;Fresnel Normal;7;66;77;76;75;111;117;114;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-295.5635,-1350.619;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;133;-135.5934,-768.9894;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1892.896,-1101.968;Inherit;False;Constant;_Float4;Float 0;2;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;123;-702.7538,-714.1176;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-498.6149,-1183.67;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1897.049,-925.9073;Inherit;False;Property;_FresnelPower;Fresnel Power;3;1;[Header];Create;True;1;Fresnel Setting;0;0;False;0;False;0;5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;26;-740.4283,-1399.682;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;28;-76.9961,-1315.348;Inherit;False;Global;_ParticleDistorionMesh;ParticleDistorionMesh;1;0;Create;True;0;0;0;False;0;False;Object;-1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;148;822.1749,-974.1162;Float;False;True;-1;5;ASEMaterialInspector;0;0;Unlit;Irua/Particle_MeshDistortion;False;False;False;False;True;True;True;True;True;False;False;False;False;False;True;False;False;False;False;False;False;Off;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;1;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;1;False;;1;False;;5;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;5;-1;-1;-1;0;False;0;0;True;_CullMode;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.ConditionalIfNode;160;503.624,-765.3131;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;134;-264.3166,-588.042;Inherit;False;Property;_FresnelColor;Fresnel Color;4;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;11.98431,11.98431,11.98431,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;152;471.6552,-550.3264;Inherit;False;Constant;_Color0;Color 0;8;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;165;325.4446,-727.4336;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ToggleSwitchNode;137;206.7579,-889.5432;Inherit;False;Property;_DistortionToggle;DistortionToggle;6;0;Create;True;0;0;0;False;0;False;1;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;166;-803.3979,-934.9674;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TwoSidedSign;168;-798.3979,-790.9674;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;130;-453.7323,-930.3559;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-778.5203,-1045.117;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-2137.349,-1094.925;Inherit;False;Property;_NormalScale;Normal Scale;1;0;Create;True;0;0;0;False;0;False;1;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1892.77,-1014.912;Inherit;False;Property;_DistortionStranth;Distortion Stranth;2;0;Create;True;0;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;173;-909.641,-1490.775;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;174;-1921.088,-1697.137;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;198;-1845.921,-1579.137;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;171;-2358.817,-1707.62;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;-1680.921,-1652.137;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;178;-1478.921,-1520.137;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;66;-1442.569,-886.47;Inherit;True;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;200;-2032.921,-1551.137;Inherit;False;3;0;FLOAT;0.5;False;1;FLOAT;0.05;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;199;-2504.921,-1481.137;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;201;-2284.03,-1549.526;Inherit;False;Property;_NormalScaleFlow;NormalScaleFlow;8;1;[Header];Create;True;1;NormalFlow X Start Y End;0;0;False;0;False;0.5,0;0.5,0.25;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ConditionalIfNode;157;491.5897,-968.0385;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;154;243.4071,-1090.198;Float;False;Global;_VRChatMirrorMode;_VRChatMirrorMode;8;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;132;145.8976,-1060.73;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;170;285.1954,-524.5129;Inherit;False;Property;_CullMode;CullMode;7;2;[IntRange];[Enum];Create;True;0;3;Off;0;Front;1;Back;2;0;True;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;117;-1776.436,-1312.153;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;111;-2136.392,-1343.107;Inherit;True;Property;_Normal;Normal;0;0;Create;True;0;0;0;False;0;False;None;1b3808e2f519e604fa59eceb40f162fc;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
WireConnection;105;0;26;0
WireConnection;105;1;109;0
WireConnection;133;0;130;0
WireConnection;133;1;123;0
WireConnection;133;2;123;4
WireConnection;133;3;134;0
WireConnection;109;0;173;0
WireConnection;109;1;123;4
WireConnection;28;0;105;0
WireConnection;148;2;157;0
WireConnection;148;9;160;0
WireConnection;160;0;154;0
WireConnection;160;2;152;4
WireConnection;160;3;165;3
WireConnection;160;4;152;4
WireConnection;165;0;137;0
WireConnection;137;0;133;0
WireConnection;137;1;132;0
WireConnection;130;4;169;0
WireConnection;169;0;166;0
WireConnection;169;1;168;0
WireConnection;173;0;117;0
WireConnection;173;1;66;0
WireConnection;174;0;171;0
WireConnection;198;0;200;0
WireConnection;198;1;200;0
WireConnection;183;0;174;0
WireConnection;183;1;198;0
WireConnection;178;0;183;0
WireConnection;66;4;169;0
WireConnection;66;1;75;0
WireConnection;66;2;76;0
WireConnection;66;3;77;0
WireConnection;200;0;201;1
WireConnection;200;1;201;2
WireConnection;200;2;199;3
WireConnection;157;0;154;0
WireConnection;157;2;152;4
WireConnection;157;3;137;0
WireConnection;157;4;152;4
WireConnection;132;0;28;0
WireConnection;132;1;133;0
WireConnection;117;0;111;0
WireConnection;117;1;178;0
WireConnection;117;5;114;0
ASEEND*/
//CHKSM=593FBC0FBFBD437F2F5ED082E10796553EB25760