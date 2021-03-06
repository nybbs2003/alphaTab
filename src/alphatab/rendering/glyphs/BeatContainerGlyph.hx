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
package alphatab.rendering.glyphs;

import alphatab.model.Beat;
import alphatab.model.Note;
import alphatab.platform.ICanvas;
import alphatab.platform.model.Color;
import alphatab.platform.model.Font;
import alphatab.rendering.Glyph;
import alphatab.rendering.layout.ScoreLayout;
import alphatab.rendering.staves.BarSizeInfo;

class BeatContainerGlyph extends Glyph implements ISupportsFinalize
{
    /**
     * pixel / fullnote ticks
     */
    private static inline var PixelPerTick:Float = 160 / 3840;
    public var beat:Beat;
    public var preNotes:BeatGlyphBase;
    public var onNotes:BeatGlyphBase;
    public var postNotes:BeatGlyphBase;
    public var ties:Array<Glyph>;

    public function new(beat:Beat) 
    {
        super(0, 0);
        this.beat = beat;
        ties = new Array<Glyph>();
    }
    
    public function finalizeGlyph(layout:ScoreLayout) : Void
    {
        if (Std.is(preNotes, ISupportsFinalize)) 
        {
            cast(preNotes, ISupportsFinalize).finalizeGlyph(layout);
        }
        if (Std.is(onNotes, ISupportsFinalize)) 
        {
            cast(onNotes, ISupportsFinalize).finalizeGlyph(layout);
        }
        if (Std.is(postNotes, ISupportsFinalize)) 
        {
            cast(postNotes, ISupportsFinalize).finalizeGlyph(layout);
        }
    }
    
    public function registerMaxSizes(sizes:BarSizeInfo)
    {
        if (sizes.getPreNoteSize(beat.start) < preNotes.width)
        {
            sizes.setPreNoteSize(beat.start, preNotes.width);
        }      
        if (sizes.getOnNoteSize(beat.start) < onNotes.width)
        {
            sizes.setOnNoteSize(beat.start, onNotes.width);
        }
        if (sizes.getPostNoteSize(beat.start) < postNotes.width)
        {
            sizes.setPostNoteSize(beat.start, postNotes.width);
        }
    }
    
    public function applySizes(sizes:BarSizeInfo)
    {
        var size:Int;
        var diff:Int;
        
        size = sizes.getPreNoteSize(beat.start);
        diff = size - preNotes.width;
        preNotes.x = 0;
        if (diff > 0) preNotes.applyGlyphSpacing(diff);
        
        size = sizes.getOnNoteSize(beat.start);
        diff = size - onNotes.width;
        onNotes.x = preNotes.x + preNotes.width;
        if (diff > 0) onNotes.applyGlyphSpacing(diff);
        
        size = sizes.getPostNoteSize(beat.start);
        diff = size - postNotes.width;
        postNotes.x = onNotes.x + onNotes.width;
        if (diff > 0) postNotes.applyGlyphSpacing(diff);

        width = calculateWidth();
    }    
    
    private function calculateWidth() : Int
    {
#if MULTIVOICE_SUPPORT
        return Std.int(beat.calculateDuration() * PixelPerTick * getScale());
#else 
        return postNotes.x + postNotes.width;
#end        
    }
    
    public override function doLayout():Void 
    {
        preNotes.x = 0;
        preNotes.index = 0;
        preNotes.renderer = renderer;
        preNotes.container = this;
        preNotes.doLayout();
        
        onNotes.x = preNotes.x + preNotes.width;
        onNotes.index = 1;
        onNotes.renderer = renderer;
        onNotes.container = this;
        onNotes.doLayout();
        
        postNotes.x = onNotes.x + onNotes.width;
        postNotes.index = 2;
        postNotes.renderer = renderer;
        postNotes.container = this;
        postNotes.doLayout();
        
        var i = beat.notes.length -1;
        while ( i >= 0 )
        {
            createTies(beat.notes[i--]);
        }
        
        width = calculateWidth();
    }
    
    private function createTies(n:Note) 
    {
        
    }
    
    public override function paint(cx:Int, cy:Int, canvas:ICanvas):Void 
    {
        // canvas.setColor(new Color(200, 0, 0, 100));
        // canvas.fillRect(cx + x, cy + y + 15 * beat.voice.index, width, 10);
        // canvas.setFont(new Font("Arial", 10));
        // canvas.setColor(new Color(0, 0, 0));
        // canvas.fillText(beat.voice.index + ":" + beat.index, cx + x, cy +y + 15 * beat.voice.index);
        
        preNotes.paint(cx + x, cy + y, canvas);
        //canvas.setColor(new Color(200, 0, 0, 100));
        //canvas.fillRect(cx + x + preNotes.x, cy + y + preNotes.y, preNotes.width, 10);

        onNotes.paint(cx + x, cy + y, canvas);
        //canvas.setColor(new Color(0, 200, 0, 100));
        //canvas.fillRect(cx + x + onNotes.x, cy + y + onNotes.y + 10, onNotes.width, 10);

        postNotes.paint(cx + x, cy + y, canvas);
        //canvas.setColor(new Color(0, 0, 200, 100));
        //canvas.fillRect(cx + x + postNotes.x, cy + y + postNotes.y + 20, postNotes.width, 10);
        
        for (t in ties)
        {
            t.renderer = renderer;
            t.paint(cx, cy + y, canvas);
        }
    }
}