//
//  Shader.vsh
//  CameraProcessing
//
//  Created by Nicholas Winters on 12/23/12.
//  Copyright (c) 2012 Nicholas Winters. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute mediump vec2 inputTextureCoordinate;

varying lowp vec4 colorVarying;
varying mediump vec2 textureCoordinate;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;
    
    textureCoordinate = inputTextureCoordinate;
    
    gl_Position = modelViewProjectionMatrix * position;
}
