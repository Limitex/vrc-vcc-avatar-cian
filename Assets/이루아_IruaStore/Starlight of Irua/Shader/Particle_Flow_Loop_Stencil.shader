// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Irua/ Particle_Flow_Loop_Stencil"
{
	Properties
	{
		[NoScaleOffset]_FlowMap("FlowMap", 2D) = "white" {}
		_FlowSpeed("FlowSpeed", Float) = 1
		_FlowStrength("FlowStrength", Range( 0 , 10)) = 0.5
		_Smoothness("Smoothness", Range( 0.01 , 10)) = 3.004941
		[NoScaleOffset]_Texture("Texture", 2D) = "white" {}
		[HDR]_Color("Color", Color) = (1,1,1,1)
		[Toggle(_ISBASECUSTOMDATA_ON)] _isBaseCustomData("isBaseCustomData", Float) = 0
		[Toggle(_ISSMOKE_ON)] _isSmoke("isSmoke", Float) = 0
		_SmokeScale("SmokeScale", Float) = 1
		[Toggle(_SOFTPARTICLE_ON)] _SoftParticle("Soft Particle", Float) = 0
		_SoftParticleFactor("Soft Particle Factor", Range( 0 , 0.999)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Stencil
		{
			Ref 2
			CompFront Equal
			CompBack Equal
		}
		Blend One One
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 4.5
		#pragma shader_feature_local _ISBASECUSTOMDATA_ON
		#pragma shader_feature_local _ISSMOKE_ON
		#pragma shader_feature_local _SOFTPARTICLE_ON
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 uv_texcoord;
			float4 uv2_texcoord2;
			float4 vertexColor : COLOR;
			float4 screenPos;
		};

		uniform sampler2D _Texture;
		uniform sampler2D _FlowMap;
		uniform float _FlowSpeed;
		uniform float _FlowStrength;
		uniform float _Smoothness;
		uniform float4 _Color;
		uniform float _SmokeScale;
		uniform float _SoftParticleFactor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_FlowMap9 = i.uv_texcoord;
			float cos82 = cos( i.uv_texcoord.w );
			float sin82 = sin( i.uv_texcoord.w );
			float2 rotator82 = mul( (tex2D( _FlowMap, uv_FlowMap9 )).rg - float2( 0.5,0.5 ) , float2x2( cos82 , -sin82 , sin82 , cos82 )) + float2( 0.5,0.5 );
			float2 blendOpSrc20 = i.uv_texcoord.xy;
			float2 blendOpDest20 = rotator82;
			float temp_output_93_0 = ( ( _Time.y * _FlowSpeed ) + i.uv2_texcoord2.x );
			#ifdef _ISBASECUSTOMDATA_ON
				float staticSwitch161 = temp_output_93_0;
			#else
				float staticSwitch161 = i.uv_texcoord.z;
			#endif
			float temp_output_1_0_g1 = staticSwitch161;
			float temp_output_17_0 = (0.0 + (( ( temp_output_1_0_g1 - floor( ( temp_output_1_0_g1 + 0.5 ) ) ) * 2 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0));
			float Tima_A23 = ( temp_output_17_0 * _FlowStrength );
			float2 lerpResult22 = lerp( i.uv_texcoord.xy , ( saturate( (( blendOpDest20 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest20 ) * ( 1.0 - blendOpSrc20 ) ) : ( 2.0 * blendOpDest20 * blendOpSrc20 ) ) )) , Tima_A23);
			float2 Flowmap_A25 = ( lerpResult22 + float2( 0,0 ) );
			float temp_output_1_0_g2 = (staticSwitch161*1.0 + 0.5);
			float Tima_B32 = ( (0.0 + (( ( temp_output_1_0_g2 - floor( ( temp_output_1_0_g2 + 0.5 ) ) ) * 2 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) * _FlowStrength );
			float2 lerpResult34 = lerp( i.uv_texcoord.xy , rotator82 , Tima_B32);
			float2 Flowmap_B37 = ( lerpResult34 + float2( 0,0 ) );
			float BlendTime48 = saturate( abs( ( 1.0 - ( temp_output_17_0 / 0.5 ) ) ) );
			float4 lerpResult43 = lerp( tex2D( _Texture, Flowmap_A25 ) , tex2D( _Texture, Flowmap_B37 ) , BlendTime48);
			float2 temp_cast_0 = (2.0).xx;
			float2 temp_cast_1 = (-1.0).xx;
			float2 uvs_TexCoord77 = i.uv_texcoord;
			uvs_TexCoord77.xy = i.uv_texcoord.xy * temp_cast_0 + temp_cast_1;
			float smoothstepResult78 = smoothstep( 1.0 , ( 1.0 - _Smoothness ) , length( uvs_TexCoord77.xy ));
			float2 appendResult116 = (float2(_SmokeScale , _SmokeScale));
			float Time96 = temp_output_93_0;
			float2 temp_cast_2 = (( Time96 * 0.2 )).xx;
			float2 uvs_TexCoord95 = i.uv_texcoord;
			uvs_TexCoord95.xy = i.uv_texcoord.xy * appendResult116 + temp_cast_2;
			float simplePerlin3D94 = snoise( float3( uvs_TexCoord95.xy ,  0.0 ) );
			simplePerlin3D94 = simplePerlin3D94*0.5 + 0.5;
			float2 temp_cast_4 = (( Time96 * -0.1 )).xx;
			float2 uvs_TexCoord101 = i.uv_texcoord;
			uvs_TexCoord101.xy = i.uv_texcoord.xy * appendResult116 + temp_cast_4;
			float simplePerlin3D100 = snoise( float3( uvs_TexCoord101.xy ,  0.0 )*2.0 );
			simplePerlin3D100 = simplePerlin3D100*0.5 + 0.5;
			float2 appendResult112 = (float2(0.0 , ( Time96 * -0.3 )));
			float2 uvs_TexCoord108 = i.uv_texcoord;
			uvs_TexCoord108.xy = i.uv_texcoord.xy * appendResult116 + appendResult112;
			float simplePerlin2D107 = snoise( uvs_TexCoord108.xy );
			simplePerlin2D107 = simplePerlin2D107*0.5 + 0.5;
			float Smoke129 = ( simplePerlin3D94 * simplePerlin3D100 * ( simplePerlin2D107 * 2.0 ) );
			#ifdef _ISSMOKE_ON
				float staticSwitch140 = Smoke129;
			#else
				float staticSwitch140 = 1.0;
			#endif
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float eyeDepth143 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float SoftParticle156 = saturate( ( ( 1.0 - _SoftParticleFactor ) * ( eyeDepth143 - ase_screenPos.w ) * 3.0 ) );
			#ifdef _SOFTPARTICLE_ON
				float staticSwitch160 = SoftParticle156;
			#else
				float staticSwitch160 = 1.0;
			#endif
			float4 Texture27 = ( ( lerpResult43 * smoothstepResult78 * _Color * i.vertexColor * staticSwitch140 * i.vertexColor.a ) * staticSwitch160 );
			o.Emission = Texture27.rgb;
			o.Alpha = i.vertexColor.a;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.CommentaryNode;157;-915.9964,-835.9152;Inherit;False;1014.661;401.5975;;9;143;144;146;147;148;149;145;153;156;SoftParticle;1,0.6383647,0.6383647,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;118;-2889.211,-1814.642;Inherit;False;1456.476;816.819;;16;105;95;97;106;94;103;112;100;109;107;101;108;116;115;129;142;GenerateSmokeMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;59;1147.244,-303.0316;Inherit;False;2303.679;1347.258;;18;26;49;43;81;80;79;27;42;28;3;41;87;139;140;141;158;159;160;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;87;1531.183,597.0556;Inherit;False;872.8224;390.3;;8;78;77;76;75;74;73;72;71;Circle Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;58;-2897.727,-837.597;Inherit;False;1889.198;919.4646;;14;24;35;9;7;37;34;22;20;25;36;21;53;82;84;Flow;1,0.8212569,0.5157232,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;57;-2891.089,251.4182;Inherit;False;2246.497;957.7697;;23;15;56;54;55;32;23;30;48;47;46;44;33;17;45;14;31;16;13;68;89;93;96;161;Time;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;45;-1376.775,967.65;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;46;-1213.283,968.7719;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;47;-1053.323,971.5209;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-2051.82,-687.5918;Inherit;False;23;Tima_A;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1250.53,-370.0166;Inherit;True;Flowmap_B;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;22;-1816.841,-774.1233;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendOpsNode;20;-2072.578,-603.4445;Inherit;False;Overlay;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1264.559,-787.597;Inherit;False;Flowmap_A;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-1491.149,-777.8879;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-2029.137,-81.08392;Inherit;False;32;Tima_B;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1315.881,513.0803;Inherit;False;Tima_A;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1552.305,549.1205;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1535.374,847.0649;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;16;-2145.839,543.5671;Inherit;True;Sawtooth Wave;-1;;1;289adb816c3ac6d489f255fc3caf5016;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;5;703.3599,200.8565;Float;False;True;-1;5;ASEMaterialInspector;0;0;Unlit;Irua/ Particle_Flow_Loop_Stencil;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;True;False;False;False;False;False;Off;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;True;2;False;;255;False;;255;False;;5;False;;0;False;;0;False;;0;False;;5;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;4;1;False;;1;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;4;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;461.4323,252.8565;Inherit;False;27;Texture;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;7;-2590.241,-492.9542;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;84;-2680.942,-240.9374;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1294.365,846.7238;Inherit;False;Tima_B;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-886.5886,971.8019;Inherit;False;BlendTime;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;44;-1618.965,958.2311;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;31;-2414.065,864.4698;Inherit;True;Sawtooth Wave;-1;;2;289adb816c3ac6d489f255fc3caf5016;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;30;-2628.432,870.0079;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;33;-2168.353,861.7668;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;17;-1900.129,540.8646;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;13;-2820.089,333.2564;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2609.32,334.6733;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-2467.51,430.388;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;-2319.29,352.3098;Inherit;False;Time;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;95;-2451.788,-1696.506;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;97;-2839.211,-1511.615;Inherit;False;96;Time;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-2613.391,-1614.722;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;94;-2223.677,-1694.054;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-2612.68,-1425.09;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;112;-2622.086,-1144.889;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;100;-2221.169,-1478.221;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-2621.118,-1246.808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;107;-2222.986,-1251.49;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;101;-2455.128,-1455.571;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;108;-2450.205,-1305.739;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;116;-2624.904,-1764.642;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-2804.183,-1764.097;Inherit;False;Property;_SmokeScale;SmokeScale;9;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;41;1759.875,330.2365;Inherit;True;Property;_TextureSample2;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;80;2619.119,520.2215;Inherit;False;Property;_Color;Color;6;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;5.992157,5.992157,5.992157,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;1743.901,783.6407;Inherit;False;Constant;_Radius;Radius;0;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;2026.356,821.4648;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;74;2035.356,755.4651;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;1610.356,733.4653;Inherit;False;Constant;_1;-1;0;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;1612.356,663.4651;Inherit;False;Constant;_2;2;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;77;1745.356,663.4651;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;78;2181.179,750.0985;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;43;2303.166,102.4162;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;1761.713,107.5186;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;81;2655.816,714.9364;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;82;-2354.749,-342.2413;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-2468.724,-781.9247;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-1521.24,-365.5253;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;34;-1804.162,-367.9005;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;1380.598,424.2225;Inherit;False;37;Flowmap_B;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;1379.902,334.9521;Inherit;False;25;Flowmap_A;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-1703.209,-1574.557;Inherit;False;Smoke;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;3254.514,253.8288;Inherit;False;Texture;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;72;1743.356,855.4647;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;3.004941;1;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;139;2354.77,471.9764;Inherit;False;129;Smoke;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;2383.139,388.9988;Inherit;False;Constant;_Float1;Float 1;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;140;2578.139,361.9988;Inherit;False;Property;_isSmoke;isSmoke;8;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-1908.36,-1572.046;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-1956.687,-1272.508;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;2080.491,50.25493;Inherit;False;48;BlendTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;26;1344.289,-85.13564;Inherit;True;Property;_Texture;Texture;5;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;1da504b1f417b1b439f433b2d0cceb49;1da504b1f417b1b439f433b2d0cceb49;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.ScreenDepthNode;143;-782.7783,-713.7648;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;144;-773.7764,-641.6511;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;146;-590.6483,-780.9506;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;147;-582.6432,-668.8403;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-579.1492,-554.6225;Inherit;False;Constant;_3;3;4;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;-419.2885,-695.2702;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-865.9963,-785.9152;Inherit;False;Property;_SoftParticleFactor;Soft Particle Factor;11;0;Create;True;0;0;0;False;0;False;0.5;0;0;0.999;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;153;-282.3651,-698.163;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;156;-143.3352,-696.7955;Inherit;False;SoftParticle;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;2890.717,255.7233;Inherit;True;6;6;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;3169.917,362.2674;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;159;3187.057,685.2808;Inherit;False;156;SoftParticle;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;160;3162.005,582.4442;Inherit;False;Property;_SoftParticle;Soft Particle;10;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-2875.355,-494.3055;Inherit;True;Property;_FlowMap;FlowMap;0;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;d569812bddbc41046baf240cd2c75750;d569812bddbc41046baf240cd2c75750;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;15;-2817.335,417.4926;Inherit;False;Property;_FlowSpeed;FlowSpeed;1;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;161;-2458.846,557.7509;Inherit;False;Property;_isBaseCustomData;isBaseCustomData;7;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1928.374,775.0669;Inherit;False;Property;_FlowStrength;FlowStrength;2;0;Create;True;0;0;0;False;0;False;0.5;4;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;162;457.2885,434.3325;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;89;-2855.714,689.1925;Inherit;False;1;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;68;-2856.713,508.8259;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;45;0;44;0
WireConnection;46;0;45;0
WireConnection;47;0;46;0
WireConnection;37;0;53;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;22;2;24;0
WireConnection;20;0;21;0
WireConnection;20;1;82;0
WireConnection;25;0;36;0
WireConnection;36;0;22;0
WireConnection;23;0;54;0
WireConnection;54;0;17;0
WireConnection;54;1;55;0
WireConnection;56;0;33;0
WireConnection;56;1;55;0
WireConnection;16;1;161;0
WireConnection;5;2;29;0
WireConnection;5;9;162;4
WireConnection;7;0;9;0
WireConnection;32;0;56;0
WireConnection;48;0;47;0
WireConnection;44;0;17;0
WireConnection;31;1;30;0
WireConnection;30;0;161;0
WireConnection;33;0;31;0
WireConnection;17;0;16;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;93;0;14;0
WireConnection;93;1;89;1
WireConnection;96;0;93;0
WireConnection;95;0;116;0
WireConnection;95;1;106;0
WireConnection;106;0;97;0
WireConnection;94;0;95;0
WireConnection;103;0;97;0
WireConnection;112;1;109;0
WireConnection;100;0;101;0
WireConnection;109;0;97;0
WireConnection;107;0;108;0
WireConnection;101;0;116;0
WireConnection;101;1;103;0
WireConnection;108;0;116;0
WireConnection;108;1;112;0
WireConnection;116;0;115;0
WireConnection;116;1;115;0
WireConnection;41;0;26;0
WireConnection;41;1;42;0
WireConnection;73;0;71;0
WireConnection;73;1;72;0
WireConnection;74;0;77;0
WireConnection;77;0;76;0
WireConnection;77;1;75;0
WireConnection;78;0;74;0
WireConnection;78;1;71;0
WireConnection;78;2;73;0
WireConnection;43;0;3;0
WireConnection;43;1;41;0
WireConnection;43;2;49;0
WireConnection;3;0;26;0
WireConnection;3;1;28;0
WireConnection;82;0;7;0
WireConnection;82;2;84;4
WireConnection;53;0;34;0
WireConnection;34;0;21;0
WireConnection;34;1;82;0
WireConnection;34;2;35;0
WireConnection;129;0;105;0
WireConnection;27;0;158;0
WireConnection;140;1;141;0
WireConnection;140;0;139;0
WireConnection;105;0;94;0
WireConnection;105;1;100;0
WireConnection;105;2;142;0
WireConnection;142;0;107;0
WireConnection;146;0;145;0
WireConnection;147;0;143;0
WireConnection;147;1;144;4
WireConnection;149;0;146;0
WireConnection;149;1;147;0
WireConnection;149;2;148;0
WireConnection;153;0;149;0
WireConnection;156;0;153;0
WireConnection;79;0;43;0
WireConnection;79;1;78;0
WireConnection;79;2;80;0
WireConnection;79;3;81;0
WireConnection;79;4;140;0
WireConnection;79;5;81;4
WireConnection;158;0;79;0
WireConnection;158;1;160;0
WireConnection;160;1;141;0
WireConnection;160;0;159;0
WireConnection;161;1;68;3
WireConnection;161;0;93;0
ASEEND*/
//CHKSM=F97FEC4C6F141B80FC6B72B741BC066075D78ED0