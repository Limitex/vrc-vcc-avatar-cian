// Made with Amplify Shader Editor v1.9.3.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Irua/Paritlce_MatCap_GPUinstancing"
{
	Properties
	{
		_Matcap("Matcap", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_NormalScale("Normal Scale", Float) = 1
		[HDR]_Color("Color", Color) = (1,1,1,1)
		_EmitPower("Emit Power", Float) = 0
		_Metalic("Metalic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 4.5
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#pragma instancing_options procedural:vertInstancingSetup
		#include "UnityStandardParticleInstancing.cginc"
		#define UNITY_PARTICLE_INSTANCE_DATA_NO_ANIM_FRAME
		#pragma only_renderers d3d11 glcore gles gles3 metal 
		#pragma surface surf Standard keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nometa noforwardadd  vertex:vert
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
		uniform float4 _Color;
		uniform float _EmitPower;
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
			float4 localvColor49 = ( i.vertexColor );
			float4 temp_output_29_0 = ( tex2D( _Matcap, ( ( ( ase_worldViewDir * (WorldNormalVector( i , UnpackScaleNormal( tex2D( _Normal, uv_Normal ), _NormalScale ) )) ) * 0.5 ) + 0.5 ).xy ) * _Color * localvColor49 );
			o.Albedo = temp_output_29_0.rgb;
			o.Emission = ( temp_output_29_0 * _EmitPower ).rgb;
			o.Metallic = _Metalic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19302
Node;AmplifyShaderEditor.RangedFloatNode;33;-1192,72.5;Inherit;False;Property;_NormalScale;Normal Scale;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-1244,-156.5;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;15;-960,-154.5;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-918,-339.5;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-726,-187.5;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-537,-74.5;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-544,-189.5;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-374,-159.5;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;7;-194,-186.5;Inherit;True;Property;_Matcap;Matcap;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;34;-60,440.5;Inherit;False;Property;_Color;Color;3;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;49;-32.34998,22.62039;Inherit;False;i.vertexColor;4;Create;0;vColor;True;False;1;45;;False;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;38;164.2204,68.41272;Inherit;False;Property;_EmitPower;Emit Power;4;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;179,-87.5;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;36;97.05188,-339.9698;Inherit;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;0;False;0;False;0;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;94.05188,-424.9698;Inherit;False;Property;_Metalic;Metalic;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;359.2204,-48.58728;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomExpressionNode;45;-178.3503,23.62039;Inherit;False;UNITY_INITIALIZE_OUTPUT(Input, o)@$vertInstancingColor(o.vertexColor)@;7;Create;2;True;v;OBJECT;;InOut;appdata_full;Inherit;False;True;o;OBJECT;;Out;Input;Inherit;False;vert;False;True;1;-1;;False;3;0;INT;0;False;1;OBJECT;;False;2;OBJECT;;False;3;INT;0;OBJECT;2;OBJECT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;551,-228;Float;False;True;-1;5;ASEMaterialInspector;0;0;Standard;Irua/Paritlce_MatCap_GPUinstancing;False;False;False;False;True;True;True;True;True;False;True;True;False;False;False;False;False;False;True;True;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;5;d3d11;glcore;gles;gles3;metal;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;3;Pragma;instancing_options procedural:vertInstancingSetup;False;;Custom;False;0;0;;Include;UnityStandardParticleInstancing.cginc;False;;Custom;False;0;0;;Define;UNITY_PARTICLE_INSTANCE_DATA_NO_ANIM_FRAME;False;;Custom;False;0;0;;1;vertex:vert;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;5;33;0
WireConnection;15;0;32;0
WireConnection;16;0;17;0
WireConnection;16;1;15;0
WireConnection;18;0;16;0
WireConnection;18;1;20;0
WireConnection;19;0;18;0
WireConnection;19;1;20;0
WireConnection;7;1;19;0
WireConnection;29;0;7;0
WireConnection;29;1;34;0
WireConnection;29;2;49;0
WireConnection;37;0;29;0
WireConnection;37;1;38;0
WireConnection;0;0;29;0
WireConnection;0;2;37;0
WireConnection;0;3;35;0
WireConnection;0;4;36;0
ASEEND*/
//CHKSM=E65D3CF37B4ED6B213C51804C02301A25F5EA4CD