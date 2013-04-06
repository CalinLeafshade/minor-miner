Shaders = 
{
	["normal"]=love.graphics.newPixelEffect([[
		extern Image normal;
		extern vec2 light;
		extern vec4 lightCol;
		extern vec4 amb;
        vec4 effect(vec4 color, Image img, vec2 texture_coords, vec2 pixel_coords) {
        	vec3 nrml = Texel(normal, texture_coords).rgb;
            nrml = nrml * 2 - 1.0f;
            vec3 l = normalize(vec3(light.x - pixel_coords.x, light.y - pixel_coords.y, 50));
            vec4 id = Texel(img, texture_coords) * max(dot(nrml,l),0.0) * lightCol;
            id.a = 1;
            return (amb * Texel(img, texture_coords)) + id;
        }
	]]),
	["spotnormal"] = love.graphics.newPixelEffect([[
			
		extern Image normal;
		extern vec3 lightPos;
		extern vec3 spotDir;
		extern float spotAngle;
		//extern float spotExp;
		extern vec4 amb;

		vec4 effect(vec4 col, Image img, vec2 texture_coords, vec2 pixel_coords) {
		    
		    vec3 n,halfV;
		    float NdotL,NdotHV;
		    vec4 color = amb;
		    float att,spotEffect;
		    
		    vec3 nrml = Texel(normal, texture_coords).rgb;
            nrml = nrml * 2 - 1.0f;
		    /* a fragment shader can't write a verying variable, hence we need
		    a new variable to store the normalized interpolated normal */
		    n = normalize(nrml);
		     
		    // Compute the ligt direction
		    vec3 lightDir = vec3(lightPos - vec3(pixel_coords.x,pixel_coords.y,0));
		     
		    /* compute the distance to the light source to a varying variable*/
		    float dist = length(lightDir);
		 
		    /* compute the dot product between normal and ldir */
		    NdotL = max(dot(n,normalize(lightDir)),0.0);
		 	//float s = spotExp;

		    if (NdotL > 0.0) {
		     
		        spotEffect = dot(normalize(spotDir), normalize(lightDir));
		        if (spotEffect > cos(spotAngle)) {
		            spotEffect = pow(spotEffect, 2);
		            //att = spotEffect / (gl_LightSource[0].constantAttenuation +
		            //        gl_LightSource[0].linearAttenuation * dist +
		            //        gl_LightSource[0].quadraticAttenuation * dist * dist);
					att = 1;
		                 
		            color += att * (Texel(img, texture_coords) * NdotL + amb);
		         
		             
		            //halfV = normalize(halfVector);
		            //NdotHV = max(dot(n,halfV),0.0);
		            //color += att * gl_FrontMaterial.specular * gl_LightSource[0].specular * pow(NdotHV,gl_FrontMaterial.shininess);
		        }
		    }
		    return color;
		}
		]])
}

