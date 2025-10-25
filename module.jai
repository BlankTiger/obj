Obj_Data :: struct {
    positions: []Vector3;
    uvs:       []Vector2;
    normals:   []Vector3;
    faces:     []Obj_Face_Idx;
    allocator: Allocator;
}

Obj_Face_Idx :: struct {
    position: int;
    uv:       int;
    normal:   int;
}

obj_load :: (filename: string) -> Obj_Data {
    data, ok := read_entire_file(filename);
    assert(ok);
    defer free(data);

    positions: [..]Vector3;
    uvs:       [..]Vector2;
    normals:   [..]Vector3;
    faces:     [..]Obj_Face_Idx;

    lines := split(data, "\n");
    for line: lines {
        if line.count == 0        continue;
        if starts_with(line, "#") continue;

        parts := split(line, " ");
        identifier := parts[0];
        if identifier == {
            case "v";
                pos := parse_vec3(parts[1], parts[2], parts[3]);
                array_add(*positions, pos);

            case "vt";
                uv := parse_uv(parts[1], parts[2]);
                array_add(*uvs, uv);

            case "vn";
                normal := parse_vec3(parts[1], parts[2], parts[3]);
                array_add(*normals, normal);

            case "f";
                _faces := parse_faces(parts[1], parts[2], parts[3]);
                array_add(*faces, .._faces);
        }
    }

    return .{
        positions = positions,
        uvs       = uvs,
        normals   = normals,
        faces     = faces,
        allocator = context.allocator,
    };
}

obj_unload :: inline (data: Obj_Data) {
    free(data.positions.data,, data.allocator);
    free(data.uvs.data,,       data.allocator);
    free(data.normals.data,,   data.allocator);
    free(data.faces.data,,     data.allocator);
}

#scope_file

parse_vec3 :: inline (x: string, y: string, z: string) -> Vector3 {
    return .{
        parse_float(*x),
        parse_float(*y),
        parse_float(*z),
    };
}

parse_uv :: inline (x: string, y: string) -> Vector2 {
    return .{
        parse_float(*x),
        parse_float(*y),
    };
}

parse_faces :: inline (first: string, second: string, third: string) -> []Obj_Face_Idx {
    pos_uv_norm_first  := split(first,  "/");
    pos_uv_norm_second := split(second, "/");
    pos_uv_norm_third  := split(third,  "/");

    return .[
        .{
            position = parse_int(*pos_uv_norm_first[0]) - 1,
            uv       = parse_int(*pos_uv_norm_first[1]) - 1,
            normal   = parse_int(*pos_uv_norm_first[2]) - 1,
        },

        .{       
            position = parse_int(*pos_uv_norm_second[0]) - 1, 
            uv       = parse_int(*pos_uv_norm_second[1]) - 1,
            normal   = parse_int(*pos_uv_norm_second[2]) - 1,
        },

        .{       
            position = parse_int(*pos_uv_norm_third[0]) - 1,
            uv       = parse_int(*pos_uv_norm_third[1]) - 1,
            normal   = parse_int(*pos_uv_norm_third[2]) - 1,
        },
    ];
}

#import "Math";
#import "Basic";
#import "String";
#import "File";
