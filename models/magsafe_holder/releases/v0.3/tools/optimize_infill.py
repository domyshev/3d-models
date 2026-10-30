#!/usr/bin/env python3
"""Apply localized strength settings without altering any printable mesh.

Usage: python3 optimize_infill.py input.3mf output.3mf
The input must be the eight-object v0.3 project without these modifiers.
"""
import sys
import uuid
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

CORE = 'http://schemas.microsoft.com/3dmanufacturing/core/2015/02'
PROD = 'http://schemas.microsoft.com/3dmanufacturing/production/2015/06'
ET.register_namespace('', CORE)
ET.register_namespace('p', PROD)
ET.register_namespace('BambuStudio', 'http://schemas.bambulab.com/package/2021')
NS = {'m': CORE}


def metadata(node, key, value):
    item = next((m for m in node.findall('metadata') if m.get('key') == key), None)
    if item is None:
        item = ET.Element('metadata', key=key)
        node.insert(len(node.findall('metadata')), item)
    item.set('value', value)


def box(resources, ident, lo, hi):
    obj = ET.SubElement(resources, f'{{{CORE}}}object', id=str(ident), type='model')
    obj.set(f'{{{PROD}}}UUID', str(uuid.uuid4()))
    mesh = ET.SubElement(obj, f'{{{CORE}}}mesh')
    vertices = ET.SubElement(mesh, f'{{{CORE}}}vertices')
    for x, y, z in [(0,0,0),(1,0,0),(1,1,0),(0,1,0),
                    (0,0,1),(1,0,1),(1,1,1),(0,1,1)]:
        ET.SubElement(vertices, f'{{{CORE}}}vertex',
                      x=str(hi[0] if x else lo[0]),
                      y=str(hi[1] if y else lo[1]),
                      z=str(hi[2] if z else lo[2]))
    triangles = ET.SubElement(mesh, f'{{{CORE}}}triangles')
    for a,b,c in [(0,2,1),(0,3,2),(4,5,6),(4,6,7),(0,1,5),(0,5,4),
                  (1,2,6),(1,6,5),(2,3,7),(2,7,6),(3,0,4),(3,4,7)]:
        ET.SubElement(triangles, f'{{{CORE}}}triangle', v1=str(a),v2=str(b),v3=str(c))


def main():
    source, target = map(Path, sys.argv[1:])
    with zipfile.ZipFile(source) as archive:
        entries = {n: archive.read(n) for n in archive.namelist()}
    config = ET.fromstring(entries['Metadata/model_settings.config'])
    model = ET.fromstring(entries['3D/3dmodel.model'])
    resources = model.find('m:resources', NS)
    objects = {o.get('id'): o for o in resources}
    ident = 100
    count = 0
    for obj in config.findall('object'):
        parts = obj.findall('part')
        assert len(parts) == 1, 'Use the original v0.3 project, without modifiers.'
        original = parts[0]
        data = {m.get('key'):m.get('value') for m in original.findall('metadata')}
        name = data['source_file']
        if name != 'support.stl' and not name.startswith('leg_'):
            continue
        metadata(obj, 'sparse_infill_density', '25%')
        metadata(obj, 'sparse_infill_pattern', 'grid')
        offset = [float(data[f'source_offset_{a}']) for a in 'xyz']
        if name == 'support.stl':
            # Print Z=0 corresponds to assembly Z=4. Solid to assembly Z=26:
            # this includes all four studs plus 6 mm above their upper roots.
            low, high = [-25,-28,-0.5], [25,28,22]
            label = 'Solid stud roots: bottom 22 mm'
        else:
            # Socket depth 8.35 mm plus its 2 mm closed backing, both leg sizes.
            low, high = [-0.5,-10,4], [10.35,10,24]
            label = 'Solid M12 socket: 10.35 mm'
        low = [a-b for a,b in zip(low,offset)]
        high = [a-b for a,b in zip(high,offset)]
        components = objects[obj.get('id')].find('m:components', NS)
        first = components[0]
        path = first.get(f'{{{PROD}}}path')
        mesh_model = ET.fromstring(entries[path.lstrip('/')])
        box(mesh_model.find('m:resources',NS),ident,low,high)
        entries[path.lstrip('/')] = ET.tostring(mesh_model,encoding='utf-8',xml_declaration=True)
        component = ET.SubElement(components,f'{{{CORE}}}component',objectid=str(ident),
                                  transform='1 0 0 0 1 0 0 0 1 0 0 0')
        component.set(f'{{{PROD}}}path',path)
        component.set(f'{{{PROD}}}UUID',str(uuid.uuid4()))
        modifier = ET.SubElement(obj,'part',id=str(ident),subtype='modifier_part')
        metadata(modifier,'name',label)
        metadata(modifier,'matrix','1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1')
        metadata(modifier,'sparse_infill_density','100%')
        metadata(modifier,'sparse_infill_pattern','zig-zag')
        ident += 1
        count += 1
        print(name, '25% overall; 100% in', label)
    assert count == 5, count
    entries['3D/3dmodel.model'] = ET.tostring(model,encoding='utf-8',xml_declaration=True)
    entries['Metadata/model_settings.config'] = ET.tostring(config,encoding='utf-8',xml_declaration=True)
    # Cached G-code and its estimates belong to the previous settings.
    for name in list(entries):
        if name.endswith('.gcode') or name == 'Metadata/slice_info.config':
            del entries[name]
    for plate in config.findall('plate'):
        for item in plate.findall('metadata'):
            if item.get('key') == 'gcode_file': item.set('value','')
    entries['Metadata/model_settings.config'] = ET.tostring(config,encoding='utf-8',xml_declaration=True)
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED) as archive:
        for name, data in entries.items(): archive.writestr(name,data)


if __name__ == '__main__':
    main()
