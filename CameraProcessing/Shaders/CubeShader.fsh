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

	pixelColor = texture2D(videoFrame, textureCoordinate);

    //gl_FragColor = colorVarying;
    //gl_FragColor = pixelColor;

    // test fragment coords:
    //gl_FragColor = vec4(textureCoordinate.x, 1.0, textureCoordinate.y, 1.0);
    
    gl_FragColor = colorVarying * pixelColor;
}
