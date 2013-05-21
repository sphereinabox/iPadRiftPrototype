//
//  Shader.fsh
//  CameraProcessing
//
//  Created by Nicholas Winters on 12/23/12.
//  Copyright (c) 2012 Nicholas Winters. All rights reserved.
//

varying lowp vec4 colorVarying;
varying mediump vec2 textureCoordinate;

precision mediump float;

uniform sampler2D videoFrame;

void main()
{
	vec4 pixelColor;

    // TODO: precalculate these. maybe make them shader uniforms
    float distortion = 0.3;
    vec2 distortion_center = vec2(0.5, 0.5);
	float distortion_radius = 0.75;
	float inv_distortion_radius = 1.0/distortion_radius;
    
    // recalculate the texture coordinate with some lens distortion
    // negative distortion is pincushion, positive is barrel.

	vec2 centerToUv = textureCoordinate-distortion_center;
    float r = length(centerToUv);
	float r_distorted = (1.0 + distortion * (r*inv_distortion_radius - 1.0));
	vec2 distortedTextureCoordinate = distortion_center + (r_distorted * centerToUv);
    
    pixelColor = texture2D(videoFrame, distortedTextureCoordinate);
    
    
//    // no distortion:
//    pixelColor = texture2D(videoFrame, textureCoordinate);
//    gl_FragColor = pixelColor; // No lighting

    //gl_FragColor = colorVarying;
    //gl_FragColor = pixelColor;

    // test fragment coords:
    //gl_FragColor = vec4(textureCoordinate.x, 1.0, textureCoordinate.y, 1.0);
    
    gl_FragColor = colorVarying * pixelColor;
}
