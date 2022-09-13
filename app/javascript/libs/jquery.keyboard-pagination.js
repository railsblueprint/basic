/*
	By Osvaldas Valutis, www.osvaldas.info
	Available for use under the MIT License
*/

;( function( $, window, document, undefined )
{
	'use strict';

	var $this		= $(),
		settings	= {},
		lastKeyUp	= 0,
		keyUpEvent  = false,
		dpTimeout	= false,
		isPaused	= false,

		navigate = function()
		{
			var $item = $();

			if( keyUpEvent.keyCode == settings.keyCodeLeft && settings.prev )
				$item = $this.find( settings.prev );

			else if( keyUpEvent.keyCode == settings.keyCodeRight && settings.next )
				$item = $this.find( settings.next );

			if( !$item.length && settings.num && settings.numCurrent )
			{
				$item = $this.find( settings.numCurrent );
				if( $item.length ) $item = keyUpEvent.keyCode == settings.keyCodeLeft ? $item.prev( settings.num ) : $item.next( settings.num );
			}

			if( $item.length )
			{
				$item = $item.find( 'a' );
				if( $item.length )
				{
					keyUpEvent.preventDefault();
					$item.get( 0 ).click();
				}
			}
		};

	$( document ).on( 'keyup.keyboardPagination', function( e )
	{
		keyUpEvent = e;

		if( !$this.length || isPaused || ( keyUpEvent.keyCode != settings.keyCodeLeft && keyUpEvent.keyCode != settings.keyCodeRight ) )
			return true;

		if( settings.first || settings.last )
		{
			if( new Date() - lastKeyUp <= settings.doublePressInt )
			{
				clearTimeout( dpTimeout );

				var $item = $();

				if( keyUpEvent.keyCode == settings.keyCodeLeft && settings.first )
					$item = $this.find( settings.first );

				else if( keyUpEvent.keyCode == settings.keyCodeRight && settings.last )
					$item = $this.find( settings.last );

				if( $item.length )
				{
					$item = $item.find( 'a' );
					if( $item.length )
					{
						keyUpEvent.preventDefault();
						$item.get( 0 ).click();
					}
				}
				if( !$item.length ) navigate();
			}
			else dpTimeout = setTimeout( navigate, settings.doublePressInt );

			lastKeyUp = new Date();
		}
		else navigate();
	});

	$.fn.keyboardPagination = function( options )
	{
		settings = $.extend(
					{
						num:			false,
						numCurrent:		false,
						prev:			false,
						next:			false,
						first:			false,
						last:			false,
						doublePressInt: 250,
						keyCodeLeft:	37,
						keyCodeRight:	39
					},
					options );

		$this = $( this ).last();

		isPaused = false;

		this.resume = function()
		{
			isPaused = false;
			return this;
		};

		this.pause = function()
		{
			isPaused = true;
			return this;
		};

		return this;
	};
})( jQuery, window, document );
