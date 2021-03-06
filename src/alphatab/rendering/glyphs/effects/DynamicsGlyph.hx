/*
 * This file is part of alphaTab.
 * Copyright c 2013, Daniel Kuschny and Contributors, All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or at your option any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */
package alphatab.rendering.glyphs.effects;

import alphatab.model.DynamicValue;
import alphatab.platform.ICanvas;
import alphatab.rendering.Glyph;
import alphatab.rendering.glyphs.MusicFont;
import alphatab.rendering.glyphs.SvgGlyph;

class DynamicsGlyph extends Glyph
{
    private var _dynamics:DynamicValue;
    
    public function new(x:Int = 0, y:Int = 0, dynamics:DynamicValue)
    {
        super(x, y);
        _dynamics = dynamics;
    }    
    
    public override function paint(cx:Int, cy:Int, canvas:ICanvas):Void 
    {
        var res = renderer.getResources();
        canvas.setColor(res.mainGlyphColor);
        
        var glyphs:Array<Glyph>;
        switch(_dynamics)
        {
            case PPP: 
                glyphs = [p(), p(), p()];
            case PP: 
                glyphs = [p(), p()];
            case P: 
                glyphs = [p()];
            case MP: 
                glyphs = [m(), p()];
            case MF: 
                glyphs = [m(), f()];
            case F: 
                glyphs = [f()];
            case FF: 
                glyphs = [f(), f()];
            case FFF: 
                glyphs = [f(), f(), f()];
        }
        
        var glyphWidth:Int = 0;
        for (g in glyphs) 
        {
            glyphWidth += g.width;
        }
        
        var startX = Std.int( (width - glyphWidth) / 2);
        
        for (g in glyphs)
        {
            g.x = startX;
            g.y = 0;
            g.renderer = renderer;
 
            g.paint(cx + x, cy + y, canvas);
            startX += g.width;
        }
    }
    
    private static inline var GlyphScale = 0.8;
    
    private function p() 
    {
        var p = new SvgGlyph(0, 0, MusicFont.DynamicP, GlyphScale,GlyphScale);
        p.width = Std.int(7 * getScale());
        return p;
    }
    
    private function m() 
    {
        var m = new SvgGlyph(0, 0, MusicFont.DynamicM, GlyphScale, GlyphScale);
        m.width = Std.int(7 * getScale());
        return m;
    }
    
    private function f() 
    {
        var f = new SvgGlyph(0, 0, MusicFont.DynamicF, GlyphScale, GlyphScale);
        f.width = Std.int(7 * getScale());
        return f;
    }
    
}