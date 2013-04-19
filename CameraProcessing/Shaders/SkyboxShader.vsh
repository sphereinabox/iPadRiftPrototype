//
//  SkyboxShader.vsh
//  CameraProcessing
//
//  Created by Nicholas Winters on 3/15/13.
//  Copyright (c) 2013 Nicholas Winters. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;
attribute mediump vec2 textureCoordinate;

varying mediump vec2 fragTextureCoordinate;
varying mediump vec4 fragColor;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix; // TODO: remove this, not used.

void main()
{
    fragTextureCoordinate = textureCoordinate;
    fragColor = color;
    gl_Position = modelViewProjectionMatrix * position;
}
