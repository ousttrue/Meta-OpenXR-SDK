const std = @import("std");
const zcc = @import("./compile_commands.zig");

const FLAGS = [_][]const u8{
    // "-DWIN32",
    "-DXR_OS_WINDOWS",
    "-DXR_USE_PLATFORM_WIN32",
    "-DXR_USE_GRAPHICS_API_OPENGL",
    // "-DXR_USE_GRAPHICS_API_OPENGL_ES",
    // "-DXR_USE_GRAPHICS_API_D3D11",
};

pub fn build(b: *std.Build) void {
    var targets = std.ArrayList(*std.Build.Step.Compile).init(b.allocator);
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "XrPassthrough",
        // .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.addCSourceFiles(.{
        .files = &.{
            // "Samples/XrSamples/XrHandsFB/Src/main.cpp",
            "Samples/XrSamples/XrPassthrough/Src/XrPassthrough.cpp",
            "Samples/XrSamples/XrPassthrough/Src/XrPassthroughGl.cpp",
            "Samples/XrSamples/XrPassthrough/Src/XrPassthroughInput.cpp",
        },
        .flags = &FLAGS,
    });
    exe.linkLibCpp();

    const openxr_dep = b.dependency("openxr", .{});

    const framework = buildSampleFramework(b, target, optimize, openxr_dep);
    exe.linkLibrary(framework);
    // exe.addIncludePath(framework.getEmittedIncludeTree());
    exe.addIncludePath(b.path("Samples/SampleXrFramework/Src"));
    exe.addIncludePath(b.path("Samples/1stParty/OVR/Include"));
    exe.addIncludePath(b.path("Samples/1stParty/utilities/include"));
    exe.addIncludePath(openxr_dep.path("include"));
    exe.addIncludePath(b.path("OpenXR"));
    exe.addIncludePath(b.path("Samples/3rdParty/khronos/openxr/OpenXR-SDK/src/common"));

    const openxr_loader = b.addStaticLibrary(.{
        .name = "openxr_loader",
        .target = target,
        .optimize = optimize,
    });
    openxr_loader.addCSourceFiles(.{
        .root = openxr_dep.path(""),
        .files = &.{
            "src/loader/loader_core.cpp",
            "src/loader/loader_instance.cpp",
            "src/loader/loader_logger.cpp",
            "src/loader/loader_logger_recorders.cpp",
            "src/loader/api_layer_interface.cpp",
            "src/loader/runtime_interface.cpp",
            "src/loader/xr_generated_loader.cpp",
            "src/loader/manifest_file.cpp",
            "src/common/object_info.cpp",
            "src/common/filesystem_utils.cpp",
            "src/xr_generated_dispatch_table.c",
            "src/xr_generated_dispatch_table_core.c",
            "src/external/jsoncpp/example/readFromStream/readFromStream.cpp",
            "src/external/jsoncpp/example/readFromString/readFromString.cpp",
            "src/external/jsoncpp/example/streamWrite/streamWrite.cpp",
            "src/external/jsoncpp/example/stringWrite/stringWrite.cpp",
            "src/external/jsoncpp/src/jsontestrunner/main.cpp",
            "src/external/jsoncpp/src/lib_json/json_reader.cpp",
            "src/external/jsoncpp/src/lib_json/json_value.cpp",
            "src/external/jsoncpp/src/lib_json/json_writer.cpp",
            "src/external/jsoncpp/src/test_lib_json/fuzz.cpp",
            "src/external/jsoncpp/src/test_lib_json/jsontest.cpp",
            "src/external/jsoncpp/src/test_lib_json/main.cpp",
        },
        .flags = &FLAGS,
    });
    openxr_loader.linkLibCpp();
    openxr_loader.addIncludePath(openxr_dep.path("include"));
    openxr_loader.addIncludePath(openxr_dep.path("src/common"));
    openxr_loader.addIncludePath(openxr_dep.path("src"));
    openxr_loader.addIncludePath(openxr_dep.path("src/external/jsoncpp/include"));
    exe.linkLibrary(openxr_loader);
    exe.linkSystemLibrary("OpenGL32");
    exe.linkSystemLibrary("Glu32");
    exe.linkSystemLibrary("Gdi32");

    b.installArtifact(exe);

    targets.append(exe) catch @panic("OOM");
    const cdb = zcc.createStep(b, targets.toOwnedSlice() catch @panic("OOM"));
    cdb.dependOn(&exe.step);
    b.step("cdb", "Create compile_commands.json").dependOn(cdb);
}

pub fn buildSampleFramework(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    openxr_dep: *std.Build.Dependency,
) *std.Build.Step.Compile {
    const lib = b.addStaticLibrary(.{
        .name = "SampleFramework",
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(openxr_dep.path("include"));

    lib.addCSourceFiles(.{
        .root = b.path("Samples/SampleXrFramework/Src"),
        .files = &.{
            // "GUI/ActionComponents.cpp",
            // "GUI/AnimComponents.cpp",
            // "GUI/CollisionPrimitive.cpp",
            // "GUI/DefaultComponent.cpp",
            // "GUI/Fader.cpp",
            // "GUI/GazeCursor.cpp",
            // "GUI/GuiSys.cpp",
            // "GUI/MetaDataManager.cpp",
            // "GUI/Reflection.cpp",
            // "GUI/ReflectionData.cpp",
            // "GUI/SoundLimiter.cpp",
            // "GUI/VRMenu.cpp",
            // "GUI/VRMenuComponent.cpp",
            // "GUI/VRMenuEvent.cpp",
            // "GUI/VRMenuEventHandler.cpp",
            // "GUI/VRMenuMgr.cpp",
            "GUI/VRMenuObject.cpp",
            // "Input/ArmModel.cpp",
            "Input/AxisRenderer.cpp",
            "Input/ControllerRenderer.cpp",
            // "Input/HandMaskRenderer.cpp",
            "Input/HandRenderer.cpp",
            // "Input/Skeleton.cpp",
            // "Input/SkeletonRenderer.cpp",
            "Input/TinyUI.cpp",
            // "Locale/OVR_Locale.cpp",
            // "Locale/tinyxml2.cpp",
            // "Model/ModelAnimationUtils.cpp",
            // "Model/ModelCollision.cpp",
            "Model/ModelFile.cpp",
            // "Model/ModelFile_OvrScene.cpp",
            // "Model/ModelFile_glTF.cpp",
            // "Model/ModelRender.cpp",
            // "Model/ModelTrace.cpp",
            "Model/SceneView.cpp",
            // "OVR_BinaryFile2.cpp",
            "OVR_FileSys.cpp",
            // "OVR_Lexer2.cpp",
            // "OVR_MappedFile.cpp",
            // "OVR_Stream.cpp",
            // "OVR_UTF8Util.cpp",
            // "OVR_Uri.cpp",
            // "PackageFiles.cpp",
            "Render/Egl.c",
            "Render/GlWrapperWin32.c",
            "Render/BeamRenderer.cpp",
            // "Render/BillBoardRenderer.cpp",
            // "Render/BitmapFont.cpp",
            // "Render/DebugLines.cpp",
            "Render/EaseFunctions.cpp",
            "Render/Framebuffer.cpp",
            // "Render/GeometryBuilder.cpp",
            "Render/GeometryRenderer.cpp",
            "Render/GlBuffer.cpp",
            "Render/GlGeometry.cpp",
            "Render/GlProgram.cpp",
            // "Render/GlTexture.cpp",
            // "Render/PanelRenderer.cpp",
            "Render/ParticleSystem.cpp",
            // "Render/PointList.cpp",
            // "Render/Ribbon.cpp",
            // "Render/SimpleGlbRenderer.cpp",
            "Render/SurfaceRender.cpp",
            // "Render/SurfaceTexture.cpp",
            "Render/TextureAtlas.cpp",
            "Render/TextureManager.cpp",
            // "System.cpp",
            "Misc/Log.c",
            "XrApp.cpp",
            //
        },
        .flags = &FLAGS,
    });
    lib.linkLibCpp();
    lib.addIncludePath(b.path("Samples/SampleXrFramework/Src"));
    lib.addIncludePath(b.path("Samples/1stParty/OVR/Include"));
    lib.addIncludePath(b.path("Samples/1stParty/utilities/include"));
    lib.addIncludePath(b.path("OpenXR"));
    lib.addIncludePath(b.path("Samples/3rdParty/khronos/openxr/OpenXR-SDK/src/common"));
    lib.addIncludePath(b.path("Samples/3rdParty/minizip/src"));
    lib.addIncludePath(b.path("Samples/3rdParty/stb/src"));
    const zlib_dep = b.dependency("zlib", .{});
    lib.addIncludePath(zlib_dep.path(""));
    return lib;
}
