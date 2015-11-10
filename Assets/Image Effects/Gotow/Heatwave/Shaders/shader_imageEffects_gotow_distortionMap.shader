Shader "Hidden/ImageEffects/Gotow/DistortionMap" {

	// this shader is used as a replacement shader for building the Distortion map
	// used by the Heatwave post effect. Distorting effects are rendered into a
	// normal map, which is used to perform uv offsets on the rendered scene, making
	// an inexpensive and simple distortion effect.

Properties {
	_MainTex ("Main Texture", 2D) = "black" {}
}

// Subshader used to replace opaque scene geometry. This shader merely outputs
// the "neutral" normal color, and is used to allow for solid objects occluding
// the distortion effects.
SubShader {
	Tags { "Queue" = "Geometry" "RenderType"="Opaque" }
	LOD 100

	Pass
	{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"

		struct v2f
		{
			float4 vertex : SV_POSITION;
		};

		v2f vert (appdata_base v)
		{
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			return fixed4(0.5,0.5,1,1);
		}
		ENDCG
	}
}

// This is a simplified version of Unity's default Particles/Alpha Blend shader,
// but with the render type modified to replace only particle effects using the
// custom distortion effect shader. This prevents other particles and Transparent
// effects from accidentally rendering as distortion.
SubShader {
	Tags { "Queue" = "Transparent" "RenderType" = "Gotow_HeatDistortion" }
	LOD 100

	Pass {
		 Cull Back
		 ZWrite Off
		 Blend srcAlpha OneMinusSrcAlpha

		 CGPROGRAM
		 #pragma vertex vert
		 #pragma fragment frag
		 #pragma fragmentoption ARB_precision_hint_fastest

		 #include "UnityCG.cginc"

		 sampler2D _MainTex;
		 float4 _MainTex_ST;

		 // Struct Input || VertOut
		 struct appdata {
				 half4 vertex : POSITION;
				 half2 texcoord : TEXCOORD0;
				 fixed4 color : COLOR;
		 };

		 //VertIn
		 struct v2f {
				 half4 pos : POSITION;
				 fixed4 color : COLOR;
				 half2 texcoord : TEXCOORD0;
		 };

		 v2f vert (appdata v)
		 {
				 v2f o;
				 o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				 o.color = v.color;
				 o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

				 return o;
		 }


		 fixed4 frag (v2f i) : COLOR
		 {
				 fixed4 col;
				 fixed4 tex = tex2D(_MainTex, i.texcoord);

				 col.rgb = i.color.rgb * tex.rgb;
				 col.a = i.color.a * tex.a;
				 return col;

		 }
		 ENDCG
	 }
}
}
