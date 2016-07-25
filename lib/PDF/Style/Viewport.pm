use v6;

class PDF::Style::Viewport {

    use PDF::Content;
    use PDF::Content::Util::Font;
    use CSS::Declarations;
    use CSS::Declarations::Units;

    has $.width = 595pt;
    has $.height = 842pt;

    sub pt($v) {
        if $v ~~ Numeric {
            my $units = $v.?key // 'pt';
            my $scale = Units.enums{$units}
                or die "unknown units: $units";
            $v / $scale
        }
        else {
            Nil
        }
    }

    method text( Str $text, CSS::Declarations :$css!) {
        my $position = $css.position;
        die "sorry can only handle 'position: absolute' at the moment"
            unless $position ~~ 'absolute';
        die "sorry cannot handle bottom positioning yet"
            unless $css.bottom eq 'auto';
        die "sorry cannot handle right positioning yet"
            unless $css.right eq 'auto';

        my $left = pt($css.left) // 0pt;
        my $top = pt($css.top) // 0pt;
        my $family = $css.font-family // 'arial';
        my $weight = $css.font-weight // 'normal';
        my $font-style = $css.font-style // 'normal';
        # todo: derive default from the canvas
        my $font-size = pt($css.font-size) // 16pt;
        my Numeric $width = pt($css.width) // self.width;

        my $height = pt($css.height) // self.height - $top;
        my $line-height = pt($css.line-height) // $font-size * 1.2;

        # todo - more investigation into auto widths & page boundarys
        warn "can't cope yet: {:$width} {:$height} {:$top} {:$left}"
            unless $width > 0 && $height > 0 && $left >= 0 && $left < self.width && $top >= 0 && $top < self.height;

        my $font = PDF::Content::Util::Font::core-font( :$family, :$weight, :style($font-style) );

        my $kern = $css.font-kerning
            && ( $css.font-kerning eq 'normal'
                 || ($css.font-kerning eq 'auto' && $font-size <= 32));

        my $align = $css.text-align eq 'left' | 'right' | 'center' | 'justify'
            ?? $css.text-align
            !! 'left';
        my $text-block = PDF::Content::Text::Block.new( :$text, :$font, :$kern, :$font-size, :$line-height, :$width, :$height, :$align );

        $text-block;
    }
}