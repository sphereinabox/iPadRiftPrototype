//
//  Shader.fsh
//  CameraProcessing
//
//  Created by Nicholas Winters on 12/23/12.
//  Copyright (c) 2012 Nicholas Winters. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
