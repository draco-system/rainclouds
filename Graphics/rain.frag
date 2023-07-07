#version 120
uniform vec2 textureSize;
uniform vec2 imageSize;
uniform float time;
uniform vec2 resolution;
uniform vec2 textureCoord;
uniform sampler2D sampler0;
uniform sampler2D samplerRandom;
in vec2 imageCoord;
uniform vec4 color;
uniform float xoff = 0.0;
uniform float yoff = 0.0;

vec2 img2tex( vec2 v ) { return v / textureSize * imageSize; }

vec3 dist (vec3 pos_arg_in)
{
   vec3 pos_arg = pos_arg_in + vec3((0.5 - vec2(xoff,yoff) / 4.0 / resolution.xy), 0.0);
   float rnd2 = texture2D(sampler0, mod(vec2(pos_arg.x+ time / 10.0, pos_arg.y / 10.0 + time / 3.0), 1.0)).x;
    rnd2 += texture2D(sampler0, mod(vec2(pos_arg.x, pos_arg.y / 5.0 + time / 5.0), 1.0)).x;
    pos_arg = pos_arg_in + vec3((0.5 - vec2(xoff,yoff) / resolution.xy), 0.0);
    float rnd = texture2D(sampler0, mod(vec2(pos_arg.x, pos_arg.y), 1.0)).x;
    float rnd3 = texture2D(sampler0, mod(vec2(pos_arg.x/10.0, pos_arg.y/10.0), 1.0)).x;
    float bg_intensity = (0.8 + rnd2 / 25.0) * min(pos_arg_in.x + pos_arg_in.y + 0.5, 2.0) / 2.0;
    float intensity = -1.0;
    float alpha = 0.0;
    const vec2 grid_step =  vec2(0.04, 0.05);
    vec2 grid_location = floor((0.5 - pos_arg.xy) / grid_step);
    vec2 start = (grid_location - 2.0) * grid_step;
    vec2 end = (grid_location + 2.0) * grid_step;

    for (float s = start.x; s < end.x; s += grid_step.x) {
        for (float t = start.y; t < end.y; t += grid_step.y) {
            vec3 pos = vec3(pos_arg.x + s, pos_arg.y + t, pos_arg.z);
            // grid displacement
		    float pos_delta_x = texture2D(sampler0, mod(vec2(s, t), 1.0)).x / 15.0;
		    float pos_delta_y = texture2D(sampler0, mod(vec2(s + 0.1, t + 0.2), 1.0)).x / 15.0;
            pos += vec3(pos_delta_x, pos_delta_y, 0) + vec3(rnd, rnd, 0.0) / 100.0; // jaggedness

            const vec3 center = vec3(0.5, 0.5, 1.0);
            const float decay_period = 30.0;
		    float rnd4 = time + texture2D(sampler0, mod(vec2(s, t), 1.0)).x * decay_period;
            float alpha_candidate = 1.0 / (50.0 + (float(mod(int(rnd4) , int(decay_period))) + fract(rnd4)) * 5.0);
            float radius = max(rnd3 * alpha_candidate / 1.0, 0.0005) ;
            alpha_candidate = min((radius - 0.003) * 500.0, 1.0);

            const vec3 lightVec = normalize(vec3(0.0, 0.0, 1.0));
            vec3 relPos = (pos - center) * vec3(1.0, resolution.y/resolution.x, 1.0);
            float d = length(relPos);
            if (d > radius) {
                continue;
            }
            float z = sqrt(radius*radius - relPos.x*relPos.x - relPos.y * relPos.y)*sin(pos.x * 3.5 + pos.y);
            vec3 rvec = normalize(vec3(relPos.x, relPos.y, z));
            float dot_product = dot(rvec, lightVec);
            dot_product = (dot_product > 0.4 ? (dot_product - 0.4) * 2.0 : 0.0);
            if (intensity < dot_product) {
                intensity = dot_product;
                alpha_candidate *= 1.0 - intensity * 0.8;

                // anti-aliasing
                if (d > radius - 0.001) {
                    alpha_candidate *= (radius - d) / 0.001;
                }            

                alpha = alpha_candidate;
            }
        }
    }/**/
    intensity = intensity < 0.0 ? bg_intensity : (intensity * alpha + bg_intensity * (1.0 - alpha));
    vec3 color = vec3(intensity * 0.8, intensity * 0.9, intensity * 0.92);
    return color;
}
void main()
{
    vec2 uv = imageCoord;
	uv.y = 1.0- uv.y;
	gl_FragColor = texture2D(sampler0, img2tex(uv));
    gl_FragColor = vec4(dist(vec3(uv, 1.0)), 1.0);
}
