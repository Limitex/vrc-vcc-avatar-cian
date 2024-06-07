// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Irua/ Particle_Flow_OneShot"
{
	Properties
	{
		[NoScaleOffset]_FlowMap("FlowMap", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0.01 , 1)) = 0.5
		_FlowStrength("FlowStrength", Float) = 0.5
		_FlowSpeed("FlowSpeed", Float) = 1
		[NoScaleOffset]_Texture("Texture", 2D) = "white" {}
		[Toggle(_ISONESHOT_ON)] _isOneShot("isOneShot", Float) = 0
		[HDR]_Color("Color", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend One One
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _ISONESHOT_ON
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _Texture;
		uniform sampler2D _FlowMap;
		uniform float _FlowSpeed;
		uniform float _FlowStrength;
		uniform float _Smoothness;
		uniform float4 _Color;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_FlowMap9 = i.uv_texcoord;
			float2 temp_output_7_0 = (tex2D( _FlowMap, uv_FlowMap9 )).rg;
			float cos82 = cos( i.uv_texcoord.w );
			float sin82 = sin( i.uv_texcoord.w );
			float2 rotator82 = mul( temp_output_7_0 - float2( 0.5,0.5 ) , float2x2( cos82 , -sin82 , sin82 , cos82 )) + float2( 0.5,0.5 );
			float2 blendOpSrc20 = i.uv_texcoord.xy;
			float2 blendOpDest20 = rotator82;
			#ifdef _ISONESHOT_ON
				float staticSwitch88 = i.uv_texcoord.z;
			#else
				float staticSwitch88 = ( _Time.y * _FlowSpeed );
			#endif
			float temp_output_1_0_g1 = staticSwitch88;
			#ifdef _ISONESHOT_ON
				float staticSwitch89 = 0.0;
			#else
				float staticSwitch89 = -1.0;
			#endif
			float temp_output_17_0 = (0.0 + (( ( temp_output_1_0_g1 - floor( ( temp_output_1_0_g1 + 0.5 ) ) ) * 2 ) - staticSwitch89) * (1.0 - 0.0) / (1.0 - staticSwitch89));
			float Tima_A23 = ( temp_output_17_0 * _FlowStrength );
			float2 lerpResult22 = lerp( i.uv_texcoord.xy , ( saturate( ( 1.0 - ( 1.0 - blendOpSrc20 ) * ( 1.0 - blendOpDest20 ) ) )) , Tima_A23);
			float2 uvs_TexCoord52 = i.uv_texcoord;
			uvs_TexCoord52.xy = i.uv_texcoord.xy * float2( 0.5,0.5 ) + float2( -0.25,-0.25 );
			float2 Flowmap_A25 = ( lerpResult22 + uvs_TexCoord52.xy );
			float temp_output_1_0_g2 = (staticSwitch88*1.0 + 0.5);
			float temp_output_33_0 = (0.0 + (( ( temp_output_1_0_g2 - floor( ( temp_output_1_0_g2 + 0.5 ) ) ) * 2 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0));
			float Tima_B32 = ( temp_output_33_0 * _FlowStrength );
			float2 lerpResult34 = lerp( i.uv_texcoord.xy , rotator82 , Tima_B32);
			float2 Flowmap_B37 = ( lerpResult34 + uvs_TexCoord52.xy );
			#ifdef _ISONESHOT_ON
				float staticSwitch92 = temp_output_33_0;
			#else
				float staticSwitch92 = 0.5;
			#endif
			float BlendTime48 = saturate( abs( ( 1.0 - ( temp_output_17_0 / staticSwitch92 ) ) ) );
			float4 lerpResult43 = lerp( tex2D( _Texture, Flowmap_A25 ) , tex2D( _Texture, Flowmap_B37 ) , BlendTime48);
			float2 temp_cast_0 = (2.0).xx;
			float2 temp_cast_1 = (-1.0).xx;
			float2 uvs_TexCoord77 = i.uv_texcoord;
			uvs_TexCoord77.xy = i.uv_texcoord.xy * temp_cast_0 + temp_cast_1;
			float smoothstepResult78 = smoothstep( 0.9 , ( 0.9 - _Smoothness ) , length( uvs_TexCoord77.xy ));
			float4 Texture27 = ( lerpResult43 * smoothstepResult78 * _Color * i.vertexColor * i.vertexColor.a );
			o.Emission = Texture27.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;59;-796.9777,-824.1991;Inherit;False;1885.073;973.0126;;13;27;43;49;42;28;3;41;26;79;80;81;87;94;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;87;-695.6799,-255.1766;Inherit;False;872.8224;390.3;;8;78;77;76;75;74;73;72;71;Circle Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;58;-2897.727,-837.597;Inherit;False;1889.198;919.4646;;16;24;35;9;7;37;34;22;20;25;36;21;53;52;82;84;97;Flow;1,0.8212569,0.5157232,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;57;-2515.49,236.0876;Inherit;False;2246.497;957.7697;;25;15;56;54;55;32;23;30;48;47;46;44;33;17;45;14;31;16;13;68;88;89;90;91;92;93;Time;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;45;-1001.176,952.3194;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;46;-837.684,953.4413;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;47;-677.7247,956.1903;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-2051.82,-687.5918;Inherit;False;23;Tima_A;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1250.53,-370.0166;Inherit;True;Flowmap_B;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;34;-1807.543,-171.799;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;22;-1816.841,-774.1233;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1264.559,-787.597;Inherit;False;Flowmap_A;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-1491.149,-777.8879;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-1487.429,-299.5946;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;41;-482.2097,-472.5264;Inherit;True;Property;_TextureSample2;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;42;-742.1552,-430.0859;Inherit;False;37;Flowmap_B;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;13;-2444.49,317.9258;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2233.721,319.3427;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;68;-2476.392,507.3932;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-940.282,497.7497;Inherit;False;Tima_A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1176.706,533.7899;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1159.775,831.7343;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;16;-1770.24,528.2365;Inherit;True;Sawtooth Wave;-1;;1;289adb816c3ac6d489f255fc3caf5016;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;867.4132,-543.8757;Inherit;False;Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;80;377.0333,-282.5412;Inherit;False;Property;_Color;Color;6;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;23.96863,23.96863,23.96863,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;81;411.1303,-94.32661;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-918.766,831.3932;Inherit;False;Tima_B;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-510.9898,956.4713;Inherit;False;BlendTime;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;44;-1243.366,942.9005;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;31;-2038.466,849.1392;Inherit;True;Sawtooth Wave;-1;;2;289adb816c3ac6d489f255fc3caf5016;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;30;-2252.833,854.6773;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-482.9615,-68.59166;Inherit;False;Constant;_Radius;Radius;0;0;Create;True;0;0;0;False;0;False;0.9;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;-200.5066,-30.7674;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;74;-191.5066,-96.76742;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-616.5072,-118.7673;Inherit;False;Constant;_1;-1;0;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-614.5073,-188.7672;Inherit;False;Constant;_2;2;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;-481.5063,-188.7672;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;43;61.08096,-700.3466;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-161.5936,-752.5079;Inherit;False;48;BlendTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-1994.338,334.5891;Inherit;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1993.338,412.5891;Inherit;False;Constant;_Float2;Float 1;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2412.736,397.162;Inherit;False;Property;_FlowSpeed;FlowSpeed;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;89;-1797.225,347.3557;Inherit;False;Property;_isOneShot;isOneShot;7;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;88;-2149.544,505.3636;Inherit;False;Property;_isOneShot;isOneShot;6;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-480.371,-695.2442;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;52;-1772.227,-494.254;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.5,0.5;False;1;FLOAT2;-0.25,-0.25;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-2468.724,-781.9247;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;92;-1484.151,997.4048;Inherit;False;Property;_isOneShot;isOneShot;8;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-1654.071,1095.281;Inherit;False;Constant;_Float3;Float 3;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;33;-1792.754,846.4362;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;17;-1524.53,525.534;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;78;-46.77031,-103.2195;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;197.7589,-46.34085;Inherit;False;Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;84;-2524.942,-165.9374;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;7;-2318.885,-491.9078;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendOpsNode;20;-2052.566,-596.2973;Inherit;False;Screen;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendOpsNode;97;-1839.137,-332.0743;Inherit;False;Screen;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-2026.95,-20.93923;Inherit;False;32;Tima_B;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-483.5063,3.232634;Inherit;False;Property;_Smoothness;Smoothness;2;0;Create;True;0;0;0;False;0;False;0.5;0.25;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;82;-2227.634,-331.8888;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;629.3498,-532.1291;Inherit;True;5;5;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;-745.9044,-572.1605;Inherit;False;25;Flowmap_A;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;26;-746.9777,-774.1991;Inherit;True;Property;_Texture;Texture;5;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;None;4bbbe90bbba920b4ca74c55cef21b763;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;55;-1552.775,759.7363;Inherit;False;Property;_FlowStrength;FlowStrength;3;0;Create;True;0;0;0;False;0;False;0.5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-2875.355,-494.3055;Inherit;True;Property;_FlowMap;FlowMap;1;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;24ba0e497e9a00c428554cec2a432876;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;29;1726.366,-25.77954;Inherit;False;27;Texture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;99;1966.844,-39.72231;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Irua/ Particle_Flow_OneShot;False;False;False;False;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;4;1;False;;1;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;45;0;44;0
WireConnection;46;0;45;0
WireConnection;47;0;46;0
WireConnection;37;0;53;0
WireConnection;34;0;21;0
WireConnection;34;1;82;0
WireConnection;34;2;35;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;22;2;24;0
WireConnection;25;0;36;0
WireConnection;36;0;22;0
WireConnection;36;1;52;0
WireConnection;53;0;34;0
WireConnection;53;1;52;0
WireConnection;41;0;26;0
WireConnection;41;1;42;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;23;0;54;0
WireConnection;54;0;17;0
WireConnection;54;1;55;0
WireConnection;56;0;33;0
WireConnection;56;1;55;0
WireConnection;16;1;88;0
WireConnection;27;0;79;0
WireConnection;32;0;56;0
WireConnection;48;0;47;0
WireConnection;44;0;17;0
WireConnection;44;1;92;0
WireConnection;31;1;30;0
WireConnection;30;0;88;0
WireConnection;73;0;71;0
WireConnection;73;1;72;0
WireConnection;74;0;77;0
WireConnection;77;0;76;0
WireConnection;77;1;75;0
WireConnection;43;0;3;0
WireConnection;43;1;41;0
WireConnection;43;2;49;0
WireConnection;89;1;90;0
WireConnection;89;0;91;0
WireConnection;88;1;14;0
WireConnection;88;0;68;3
WireConnection;3;0;26;0
WireConnection;3;1;28;0
WireConnection;92;1;93;0
WireConnection;92;0;33;0
WireConnection;33;0;31;0
WireConnection;17;0;16;0
WireConnection;17;1;89;0
WireConnection;78;0;74;0
WireConnection;78;1;71;0
WireConnection;78;2;73;0
WireConnection;94;0;78;0
WireConnection;7;0;9;0
WireConnection;20;0;21;0
WireConnection;20;1;82;0
WireConnection;97;0;21;0
WireConnection;97;1;7;0
WireConnection;82;0;7;0
WireConnection;82;2;84;4
WireConnection;79;0;43;0
WireConnection;79;1;78;0
WireConnection;79;2;80;0
WireConnection;79;3;81;0
WireConnection;79;4;81;4
WireConnection;99;2;29;0
ASEEND*/
//CHKSM=897BBEE2B00B9869163C4ADDFC8090A5BE799A2D