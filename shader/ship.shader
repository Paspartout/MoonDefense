shader_type canvas_item;
uniform bool flash_white;
const vec3 WHITE = vec3(1.0);

void fragment()
{
	vec4 color = texture(TEXTURE, UV);
	
	if (flash_white)
	{
		float val = abs(sin(TIME * 10.0f));
		COLOR = mix(vec4(WHITE, color.a), color, val);
	}
	else
	{
		COLOR = color;
	}
}