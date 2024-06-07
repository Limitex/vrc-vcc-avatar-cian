// Made with Amplify Shader Editor v1.9.3.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Irua/Paritlce_MatCapGlass_GPUinstancing"
{
	Properties
	{
		_Matcap("Matcap", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_NormalScale("Normal Scale", Float) = 1
		[HDR][Header(Main)]_MainColor("MainColor", Color) = (1,1,1,1)
		_EmitPower("Emit Power", Range( 0 , 1)) = 0
		[Header(Surface)]_Metalic("Metalic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HDR][Header(RimLight)]_FresnelColor("Fresnel Color", Color) = (1,1,1,1)
		_FresnelBias("Fresnel Bias", Range( 0 , 1)) = 0
		_FresnelScale("Fresnel Scale", Range( 0 , 1)) = 1
		_FresnelPower("Fresnel Power", Range( 0 , 8)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Blend One OneMinusSrcAlpha
		BlendOp Max
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 4.5
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#include "UnityStandardParticleInstancing.cginc"
		#pragma instancing_options procedural:vertInstancingSetup
		#define UNITY_PARTICLE_INSTANCE_DATA_NO_ANIM_FRAME
		#pragma only_renderers d3d11 glcore gles gles3 metal 
		#pragma surface surf Standard keepalpha noshadow exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap nometa noforwardadd  vertex:vert
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float4 vertexColor;
		};

		uniform sampler2D _Matcap;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _NormalScale;
		uniform float4 _MainColor;
		uniform float _EmitPower;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _FresnelColor;
		uniform float _Metalic;
		uniform float _Smoothness;


		void vert( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			vertInstancingColor(o.vertexColor);
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float4 tex2DNode7 = tex2D( _Matcap, ( ( ( ase_worldViewDir * (WorldNormalVector( i , UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _NormalScale ) )) ) * 0.5 ) + 0.5 ).xy );
			float4 localvColor67 = ( i.vertexColor );
			o.Albedo = ( tex2DNode7 * localvColor67 * _MainColor ).rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float fresnelNdotV44 = dot( ase_normWorldNormal, ase_worldViewDir );
			float fresnelNode44 = ( _FresnelBias + _FresnelScale * pow( max( 1.0 - fresnelNdotV44 , 0.0001 ), _FresnelPower ) );
			o.Emission = ( ( tex2DNode7 * localvColor67 * _EmitPower ) + ( localvColor67 * ( fresnelNode44 * _FresnelColor ) ) ).rgb;
			o.Metallic = _Metalic;
			o.Smoothness = _Smoothness;
			o.Alpha = _MainColor.a;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19302
Node;AmplifyShaderEditor.RangedFloatNode;33;-1192,72.5;Inherit;False;Property;_NormalScale;Normal Scale;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-1244,-156.5;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-918,-339.5;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;15;-931.8931,-163.869;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;41;-710.3848,874.7515;Inherit;False;1587.484;773.6995;RimLight;6;43;42;44;53;52;51;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-726,-187.5;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-537,-74.5;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-544,-189.5;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;51;56.23672,1019.136;Inherit;False;Property;_FresnelBias;Fresnel Bias;9;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;58.1768,1091.458;Inherit;False;Property;_FresnelScale;Fresnel Scale;10;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;56.25365,1165.356;Inherit;False;Property;_FresnelPower;Fresnel Power;11;0;Create;True;0;0;0;False;0;False;1;6;0;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-374,-159.5;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;44;342.5538,916.8475;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;42;109.8755,1305.185;Inherit;False;Property;_FresnelColor;Fresnel Color;8;2;[HDR];[Header];Create;True;1;RimLight;0;0;False;0;False;1,1,1,1;2.996078,2.996078,2.996078,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-194,-186.5;Inherit;True;Property;_Matcap;Matcap;0;0;Create;True;0;0;0;False;0;False;-1;None;c61fd2a264473fc45ab67b03de893545;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;635.5411,1135.023;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;38;432.2358,-126.9316;Inherit;False;Property;_EmitPower;Emit Power;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;67;368.0027,65.09417;Inherit;False;i.vertexColor;4;Create;0;vColor;True;False;1;45;;False;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;745.9171,135.5483;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;720.114,-113.4207;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;34;-129.6993,276.123;Inherit;False;Property;_MainColor;MainColor;3;2;[HDR];[Header];Create;True;1;Main;0;0;False;0;False;1,1,1,1;2.996078,2.996078,2.996078,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;372.3515,-250.7142;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;953.9171,1.54834;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;36;132.0519,-386.9698;Inherit;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;0;False;0;False;0;0.75;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;129.0519,-464.9698;Inherit;False;Property;_Metalic;Metalic;6;1;[Header];Create;True;1;Surface;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;66;227.068,61.0285;Inherit;False;UNITY_INITIALIZE_OUTPUT(Input, o)@$vertInstancingColor(o.vertexColor)@;7;Create;2;True;v;OBJECT;;InOut;appdata_full;Inherit;False;True;o;OBJECT;;Out;Input;Inherit;False;vert;False;True;1;-1;;False;3;0;INT;0;False;1;OBJECT;;False;2;OBJECT;;False;3;INT;0;OBJECT;2;OBJECT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1263.758,-236.3902;Float;False;True;-1;5;ASEMaterialInspector;0;0;Standard;Irua/Paritlce_MatCapGlass_GPUinstancing;False;False;False;False;True;True;True;True;True;False;True;True;False;False;True;False;False;False;True;True;False;Back;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;ForwardOnly;5;d3d11;glcore;gles;gles3;metal;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;3;1;False;;10;False;;0;5;False;;10;False;;5;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;4;-1;-1;-1;0;False;0;0;False;;-1;0;False;;3;Include;UnityStandardParticleInstancing.cginc;False;;Custom;False;0;0;;Pragma;instancing_options procedural:vertInstancingSetup;False;;Custom;False;0;0;;Define;UNITY_PARTICLE_INSTANCE_DATA_NO_ANIM_FRAME;False;;Custom;False;0;0;;1;vertex:vert;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;5;33;0
WireConnection;15;0;32;0
WireConnection;16;0;17;0
WireConnection;16;1;15;0
WireConnection;18;0;16;0
WireConnection;18;1;20;0
WireConnection;19;0;18;0
WireConnection;19;1;20;0
WireConnection;44;1;51;0
WireConnection;44;2;52;0
WireConnection;44;3;53;0
WireConnection;7;1;19;0
WireConnection;43;0;44;0
WireConnection;43;1;42;0
WireConnection;64;0;67;0
WireConnection;64;1;43;0
WireConnection;50;0;7;0
WireConnection;50;1;67;0
WireConnection;50;2;38;0
WireConnection;29;0;7;0
WireConnection;29;1;67;0
WireConnection;29;2;34;0
WireConnection;65;0;50;0
WireConnection;65;1;64;0
WireConnection;0;0;29;0
WireConnection;0;2;65;0
WireConnection;0;3;35;0
WireConnection;0;4;36;0
WireConnection;0;9;34;4
ASEEND*/
//CHKSM=5E98FA23AFB1CC557225BB16375609AD696F67BE