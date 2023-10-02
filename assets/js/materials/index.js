// chunks
import { ShaderChunk } from 'three'
import { glslifyStrip } from '../utils'
import defaultVert from '../../../glsl/includes/default/vert.glsl'
import defaultFrag from '../../../glsl/includes/default/frag.glsl'
import normalsVert from '../../../glsl/includes/normals/vert.glsl'
import dynamicBaseVertPars from '../../../glsl/includes/dynamicBase/vertPars.glsl'
import dynamicBaseVert from '../../../glsl/includes/dynamicBase/vert.glsl'
import dynamicBaseFragPars from '../../../glsl/includes/dynamicBase/fragPars.glsl'
import dynamicBaseFrag from '../../../glsl/includes/dynamicBase/frag.glsl'

import cubeUVreflectionFrag from '../../../glsl/includes/utils/cubeUVreflectionFrag.glsl'
import BackFaceMaterial from './backface/BackFaceMaterial'
import GlassMaterial from './glass/GlassMaterial'
import GradientMaterial from './gradient/GradientMaterial'
import BackgroundMaterial from './background/BackgroundMaterial'
import StairsMaterial from './stairs/StairsMaterial'
import ProjectMaterial from './project/ProjectMaterial'
import ParticleMaterial from './particle/ParticleMaterial'

// materials
import BasicMaterial from './basic/BasicMaterial'
import TestMaterial from './test/TestMaterial'

function setupShaderChunks() {
	ShaderChunk.defaultVert = glslifyStrip(defaultVert)
	ShaderChunk.defaultFrag = glslifyStrip(defaultFrag)
	ShaderChunk.normalsVert = glslifyStrip(normalsVert)

	ShaderChunk.cubeUVreflectionFrag = glslifyStrip(cubeUVreflectionFrag)

	ShaderChunk.dynamicBaseVertPars = glslifyStrip(dynamicBaseVertPars)
	ShaderChunk.dynamicBaseVert = glslifyStrip(dynamicBaseVert)
	ShaderChunk.dynamicBaseFragPars = glslifyStrip(dynamicBaseFragPars)
	ShaderChunk.dynamicBaseFrag = glslifyStrip(dynamicBaseFrag)
}

export {
	setupShaderChunks,
	BasicMaterial,
	TestMaterial,
	BackFaceMaterial,
	GlassMaterial,
	GradientMaterial,
	BackgroundMaterial,
	ProjectMaterial,
	ParticleMaterial,
	StairsMaterial
}