#version 120
#define saturate(x) clamp(x,0.,1.)
#define rgb(r,g,b) (vec3(r,g,b)/255.)


float rand(float x) { return fract(sin(x) * 71523.5413291); }

float rand(vec2 x) { return rand(dot(x, vec2(13.4251, 15.5128))); }

float noise(vec2 x)
{
    vec2 i = floor(x);
    vec2 f = x - i;
    f *= f*(3.-2.*f);
    return mix(mix(rand(i), rand(i+vec2(1,0)), f.x),
               mix(rand(i+vec2(0,1)), rand(i+vec2(1,1)), f.x), f.y);
}

float fbm(vec2 x)
{
    float r = 0.0, s = 1.0, w = 1.0;
    for (int i=0; i<5; i++)
    {
        s *= 2.0;
        w *= 0.5;
        r += w * noise(s * x);
    }
    return r;
}

float cloud(vec2 uv, float scalex, float scaley, float density, float sharpness, float speed)
{
    return pow(saturate(fbm(vec2(scalex,scaley)*(uv+vec2(speed,0)*iTime))-(1.0-density)), 1.0-sharpness);
}


#define NUM_LIGHTS 12

vec4 lightArray[NUM_LIGHTS];
vec3 lightColours[NUM_LIGHTS];

const float kPI = 3.141592654;

struct C_Ray
{
    vec3 vOrigin;
    vec3 vDir;
};
C_Ray ray;

vec2 coord;

//----------------------------------------------------------------------------------------
float sMin( float a, float b )
{
    float k = 1.5;
	float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.-h);
}

//-----------------------------------------------------------------------------------------
vec3 RotateY( const in vec3 vPos, const in float ang)
{
	float s = sin(ang);
	float c = cos(ang);
	vec3 vResult = vec3( c * vPos.x + s * vPos.z, vPos.y, -s * vPos.x + c * vPos.z);

	return vResult;
}

//-----------------------------------------------------------------------------------------
float Hash(in vec2 p)
{
	return fract(sin(dot(p, vec2(27.16898, 28.90563))) * 44549.5473453);
}

//-----------------------------------------------------------------------------------------
float Noise(in vec2 p)
{
	vec2 f;
	f = fract(p);			// Separate integer from fractional
    p = floor(p);
    f = f*f*(3.0-2.0*f);	// Cosine interpolation approximation
    float res = mix(mix(Hash(p),
						Hash(p + vec2(1.0, 0.0)), f.x),
					mix(Hash(p + vec2(0.0, 1.0)),
						Hash(p + vec2(1.0, 1.0)), f.x), f.y);
    return res;
}

//----------------------------------------------------------------------------------------
float RoundBox( vec3 p, vec3 b)
{
	return length(max(abs(p)-b,0.0))-.5;
}

//-----------------------------------------------------------------------------------------
float GetDistanceBox(const in vec3 vPos, const in vec3 vDimension)
{
	return length(max(abs(vPos)-vDimension,0.0));
}

//-----------------------------------------------------------------------------------------
float MapToScene( const in vec3 vPos )
{   
	float fResult = 1000.0;
	
	float fFloorDist = vPos.y + 3.2;	
	fResult = min(fResult, fFloorDist);
	

	
	vec3 vBuilding2Pos = vec3(60.0, 0.0, 55.0);
	const float fBuilding2Radius = 100.0;
	vec3 vBuilding2Offset = vBuilding2Pos - vPos;
	float fBuilding2Dist = length(vBuilding2Offset.xz) - fBuilding2Radius;
	fBuilding2Dist = max(vBuilding2Offset.z - 16.0, -fBuilding2Dist); // back only
	
	fResult = min(fResult, fBuilding2Dist);

	
	vec3 vCabDomain = vPos;
	vCabDomain -= vec3(-1.4, -1.55,29.5);
	vCabDomain = RotateY(vCabDomain, 0.1);
	float fCabDist = RoundBox(vCabDomain+vec3(0.0, .85, 0.0), vec3(.8, .54, 2.5));
	fResult = min(fResult, fCabDist);
	fCabDist = RoundBox(vCabDomain, vec3(.6, 1.2, 1.2));
	fResult = sMin(fResult, fCabDist);

	vec3 vBusDomain = vPos;
	vBusDomain -= vec3(-15., 0.0, 29.5);
	vBusDomain = RotateY(vBusDomain, 0.35);
	float fBusDist = RoundBox(vBusDomain, vec3(.55, 1.8, 4.0));
		
	fResult = min(fResult, fBusDist);
		
	vec3 vBusShelter = vPos;
	vBusShelter -= vec3(7.5, -2.0, 30.0);
	vBusShelter = RotateY(vBusShelter, 0.3);
	float fBusShelterDist = RoundBox(vBusShelter, vec3(.725, 5.3, 1.7));
		
	fResult = min(fResult, fBusShelterDist);
	

	
	return fResult;
}

//----------------------------------------------------------------------------------------
float Raymarch( const in C_Ray ray )
{        
    float fDistance = .1;
    bool hit = false;
    for(int i=0;i < 50; i++)
    {
			float fSceneDist = MapToScene( ray.vOrigin + ray.vDir * fDistance );
			if(fSceneDist <= 0.01 || fDistance >= 150.0)
			{
				hit = true;
                break;
			} 

        	fDistance = fDistance + fSceneDist;
	}
	
	return fDistance;
}

//----------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------
void GetCameraRay( const in vec3 vPos, const in vec3 vForwards, const in vec3 vWorldUp, out C_Ray ray)
{
    vec2 vUV = coord.xy;
    vec2 vViewCoord = vUV * 2.0 - 1.0;	

	vViewCoord.y *= -1.0;

    ray.vOrigin = vPos;

    vec3 vRight = normalize(cross(vWorldUp, vForwards));
    vec3 vUp = cross(vRight, vForwards);
        
    ray.vDir = normalize( vRight * vViewCoord.x + vUp * vViewCoord.y + vForwards);    
}

//----------------------------------------------------------------------------------------
void GetCameraRayLookat( const in vec3 vPos, const in vec3 vInterest, out C_Ray ray)
{
	vec3 vForwards = normalize(vInterest - vPos);
	vec3 vUp = vec3(0.0, 1.0, 0.0);

	GetCameraRay(vPos, vForwards, vUp, ray);
}

//----------------------------------------------------------------------------------------

float hash(float x)
{
	return fract(21654.6512 * sin(385.51 * x));
}
float hash( in vec2 p ) 
{
    return fract(sin(p.x*15.32+p.y*35.78) * 43758.23);
}

vec2 hash2(vec2 p)
{
	return vec2(hash(p*.754),hash(1.5743*p.yx+4.5891))-.5;
}
vec2 hash2b(vec2 p)
{
	return vec2(hash(p*.754),hash(1.5743*p+4.5476351));
}
vec2 add = vec2(1.0, 0.0);

vec2 noise2(vec2 x)
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    
    vec2 res = mix(mix( hash2(p),          hash2(p + add.xy),f.x),
                    mix( hash2(p + add.yx), hash2(p + add.xx),f.x),f.y);
    return res;
}

vec2 fbm2(vec2 x)
{
    vec2 r = vec2(0.0);
    float a = 1.0;
    
    for (int i = 0; i < 8; i++)
    {
        r += abs(noise2(x)+.5 )* a;
        x *= 2.;
        a *= .5;
    }
     
    return r;
}

float dseg( vec2 ba, vec2 pa )
{
	
	float h = clamp( dot(pa,ba)/dot(ba,ba), -0.2, 1. );	
	return length( pa - ba*h );
}

float arc(vec2 x,vec2 p, vec2 dir)
{
    vec2 r = p;
    float d=10.;
    for (int i = 0; i < 5; i++)
    {
        vec2 s= noise2(r+iTime)+dir;
        d=min(d,dseg(s,x-r));
        r +=s;      
    }
    return d*3.;
    
}


float thunderbolt(vec2 x,vec2 tgt)
{
    vec2 r = tgt;
    float d=1000.;
    float dist=length(tgt-x);
     
    for (int i = 0; i < 19; i++)
    {
        if(r.y>x.y+.5)break;
        vec2 s= (noise2(r+iTime)+vec2(0.,.7))*2.;
        dist = dseg(s,x-r);
        d=min(d,dist);
        
        r +=s;
        if(i-(i/5)*5==0){
            if(i-(i/10)*10==0)d=min(d,arc(x,r,vec2(.3,.5)));
            else d=min(d,arc(x,r,vec2(-.3,.5)));
        }
    }
    return exp(-5.*d)+.2*exp(-1.*dist);
   
}




//----------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// Yes, that's right, this is done for EVERY pixel! Haha - *gulp*
	// X, Y, Z, POWER...
	
	// R, G, B...
	
    vec3 vCameraPos = vec3(0.0, 0.0, 9.8);
	float ang = iTime * .3 + 3.4;
	float head = pow(abs(sin(ang*8.0)), 1.5) * .15;
	vCameraPos += vec3(cos(ang) * 2.5, head,  sin(ang) * 8.5);
    coord = fragCoord.xy / iResolution.xy;
	
	vec3 vCameraIntrest = vec3(-1.0, head, 25.0);
	GetCameraRayLookat( vCameraPos, vCameraIntrest, ray);
	vec3 originalRayDir = ray.vDir;

    //float fHitDist = Raymarch(ray);
	//vec3 vHitPos = ray.vOrigin + ray.vDir * fHitDist;
	//vec3 vHitPos = vCameraPos + ray.vDir * fHitDist;
	vec3 normal;
	vec3 col = vec3(0.0);
	

	
	// Twelve layers of rain sheets...
	vec2 q = fragCoord.xy/iResolution.xy;
	float dis = 1.;
    //col = vec3(0.5,0.5,0.5);
    col = mix(rgb(151., 176., 201.), rgb(105, 117, 135), coord.y);//sky
	for (int i = 0; i < 2; i++)//i为大小
	{
		//vec3 plane = vCameraPos + originalRayDir * dis;
		//plane.z -= (texture(iChannel3, q*iTime).x*3.5);
		//if (plane.z < vHitPos.z)
		//{
			float f = 1.;

			vec2 st =  f * (q * vec2(-3.5, .05)+vec2(-iTime*.1+q.y*.11, iTime*.07));//y*.2风大小
            //vec2 st =  f * (q * vec2(1.5, .05)+vec2(-iTime*.1+q.y*.2, iTime*.12));
			f = (texture(iChannel3, st * .5, -99.0).x + texture(iChannel3, st*.5, -99.0).y);
			f = clamp(pow(abs(f)*.5, 25.0) * 10.0, 0.00, q.y*.4+.05);//y方向越下到底部，透明度降低
            //f = clamp(pow(abs(f)*.5, 29.0) * 140.0, 0.00, q.y*.4+.05);//29.0能见度

			vec3 bri = vec3(.15);//雨可见度

			col += bri*f;
		//}

	}
	//col = clamp(col, 0.0, 1.0);
			
	//col = mix(vec3(0), col, smoothstep(2.25, 4.0, iTime));
	//col = pow(col, vec3(1.1));
    col = mix(col, vec3(0.9), 0.7*cloud(coord,4.,10.,1.9,0.95,0.05) * cloud(coord,2.,2.,0.5,0.15,0.025)*coord.y);
    
    float cpos2 = coord.y - 0.2;
    float cloudPos2 = exp(-10.*cpos2*cpos2);
    col = mix(col, vec3(0.8), 0.8 * cloud(coord,2.,2.5,0.50,0.15,0.01)*cloudPos2);
    
    /*
    vec2 p = 2.*fragCoord.xy/iResolution.yy-1.;
    vec2 d;
    vec2 tgt = vec2(1., -8.);
    float c=0.;
    
        
    float t = hash(floor(5.*iTime));
    tgt+=8.*hash2b(tgt+t);
    if(hash(t+2.3)>.8)
	{
		c= thunderbolt(p*10.+2.*fbm2(5.*p),tgt);	
		col+=clamp(1.7*vec3(0.8,.7,.9)*c,0.,1.);	
	}
*/
    
    
	
	fragColor = vec4(col, 1.0);
}
	