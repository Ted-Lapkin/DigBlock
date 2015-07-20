#ifdef GL_ES
	precision mediump float;
#endif

uniform sampler2D u_DepthMap;
uniform sampler2D u_Water;
uniform sampler2D u_Dirt;
uniform sampler2D u_GrassSide;
uniform sampler2D u_GrassTop;
uniform float u_Alpha;
uniform float u_Depth;
varying vec2 v_DiffuseUV;
varying vec2 v_DepthMap;
varying float v_Tex;
varying float v_Light;
varying float v_DistToLight;

vec3 rgb (int i) {
	if(i==0) return texture2D(u_Water, v_DiffuseUV).rgb;
	else if(i==1) return texture2D(u_Dirt, v_DiffuseUV).rgb;
	else if(i==2) return texture2D(u_GrassSide, v_DiffuseUV).rgb;
	else return texture2D(u_GrassTop, v_DiffuseUV).rgb;
}

float depth(vec2 xy) {
	float bias = u_Depth*50.0;
	vec4 rgba = texture2D(u_DepthMap, xy);
	float compare = rgba.r + rgba.g + rgba.b + rgba.a;
	if(v_DistToLight>(compare+bias))
		return 0.0;
	else return 0.5;
}

float avgDepth() {
	float offset1 = u_Depth;
	float offset2 = 1.5*u_Depth;
	float offset3 = 2.0*u_Depth;
	float toReturn = depth(v_DepthMap);
	toReturn += depth(vec2(v_DepthMap.x+offset1,v_DepthMap.y+offset1));
	toReturn += depth(vec2(v_DepthMap.x-offset1,v_DepthMap.y-offset1));
	toReturn += depth(vec2(v_DepthMap.x+offset2,v_DepthMap.y));
	toReturn += depth(vec2(v_DepthMap.x-offset2,v_DepthMap.y));
	toReturn += depth(vec2(v_DepthMap.x,v_DepthMap.y+offset2));
	toReturn += depth(vec2(v_DepthMap.x,v_DepthMap.y-offset2));
	toReturn += depth(vec2(v_DepthMap.x+offset3,v_DepthMap.y+offset3));
	toReturn += depth(vec2(v_DepthMap.x-offset3,v_DepthMap.y-offset3));
	toReturn /= 9.0;
	return 0.5 + toReturn;
}

void main() {
	vec3 final;
	float avgLight;
	if(v_Light>=0.6) {
		avgLight = avgDepth()*v_Light;
	} else {
		avgLight = v_Light;
	}
	gl_FragColor.rgb = rgb(int(v_Tex))*avgLight;
	gl_FragColor.a = u_Alpha;
}