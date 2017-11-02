﻿Shader "Custom/MainShader" {
	// Properties copy pasted from standard shader
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo", 2D) = "white" {}

	_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		_GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
		[Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

		[Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
		_MetallicGlossMap("Metallic", 2D) = "white" {}

	[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

		_BumpScale("Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}

	_Parallax("Height Scale", Range(0.005, 0.08)) = 0.02
		_ParallaxMap("Height Map", 2D) = "black" {}

	_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
		_OcclusionMap("Occlusion", 2D) = "white" {}

	_EmissionColor("Color", Color) = (0,0,0)
		_EmissionMap("Emission", 2D) = "white" {}

	_DetailMask("Detail Mask", 2D) = "white" {}

	_DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
	_DetailNormalMapScale("Scale", Float) = 1.0
		_DetailNormalMap("Normal Map", 2D) = "bump" {}

	[Enum(UV0,0,UV1,1)] _UVSec("UV Set for secondary textures", Float) = 0


		// Blending state
		[HideInInspector] _Mode("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend("__src", Float) = 1.0
		[HideInInspector] _DstBlend("__dst", Float) = 0.0
		[HideInInspector] _ZWrite("__zw", Float) = 1.0
	}
	SubShader {
		UsePass "Standard/FORWARD"
		UsePass "Standard/FORWARD_DELTA"
		UsePass "Standard/SHADOWCASTER"
		UsePass "Standard/DEFERRED"
		UsePass "Standard/META"
		
		Pass {
			Name "FOG_PASS"
			Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma debug

			#include "UnityCG.cginc"

			#define FOG_COLOR fixed4(0.75, 0.75, 0.85, 1)
			#define FOG_DISTANCE 0.2

			uniform int _FogEnabled;

			struct vInput {
				float4 vertex : POSITION;
			};

			struct fInput {
				float4 position : SV_POSITION;
			};

			fInput vert(vInput i) {
				fInput o;
				o.position = UnityObjectToClipPos(i.vertex);

				return o;
			}

			fixed4 frag(fInput i) : SV_TARGET{
				fixed fogStrength = (1 - i.position.z * FOG_DISTANCE / _ProjectionParams.w);
				fixed4 fogLight = FOG_COLOR * fogStrength * (_FogEnabled ? 1 : 0);
				return fogLight;
			}

			ENDCG
		}
		Pass {
			Name "AMBIENT_PASS"
			Cull Off
			ZWrite Off
			Blend SrcAlpha One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma debug

			#include "UnityCG.cginc"

			#define AMBIENT_LIGHT_COLOR fixed4(0.884, 0.72, 1, 0.25)

			uniform int _Night;

			struct vInput {
				float4 vertex : POSITION;
			};

			struct fInput {
				float4 position : SV_POSITION;
			};

			fInput vert(vInput i) {
				fInput o;
				o.position = UnityObjectToClipPos(i.vertex);

				return o;
			}

			fixed4 frag(fInput i) : SV_TARGET {
				fixed4 ambientLight = AMBIENT_LIGHT_COLOR * (_Night ? 0 : 1);
				return ambientLight;
			}

			ENDCG
		}
		
	}
}
