//
//  SkyboxShader.fsh
//  CameraProcessing
//
//  Created by Nicholas Winters on 3/14/13.
//  Copyright (c) 2013 Nicholas Winters. All rights reserved.
//

varying mediump vec2 fragTextureCoordinate;
varying mediump vec4 fragColor;

precision mediump float;

uniform sampler2D texture;

void main()
{
//    gl_FragColor = fragColor * texture2D(texture, fragTextureCoordinate);
    gl_FragColor = texture2D(texture, fragTextureCoordinate);
}
