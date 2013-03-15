//
//  SkyboxShader.vsh
//  CameraProcessing
//
//  Created by Nicholas Winters on 3/15/13.
//  Copyright (c) 2013 Nicholas Winters. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal; // TODO: remove this, not used.
attribute mediump vec2 inputTextureCoordinate;

varying mediump vec2 textureCoordinate;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix; // TODO: remove this, not used.

void main()
{
    textureCoordinate = inputTextureCoordinate;
    vec3 normalTemp = normal;
    gl_Position = modelViewProjectionMatrix * position;
}
