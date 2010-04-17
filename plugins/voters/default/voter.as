/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The skin.as file can be used by your skin to hook into the Dash Media Player and 
 * completely customize how the player behaves.  It allows you to use many of the facilities already
 * placed in the Dash Media Player so that you can truely have your very own player using the power
 * of the Dash Media Player
 **/


function getVoter( _style:String ) : MovieClip
{
	var voter:MovieClip = null;
   if( _style == "node" ) {
		voter = new mcVoter();
	}
	else if( _style == "teaser" ) {
		voter = new mcTeaserVoter();
	}
	return voter;
}

/**
 * Returns the layout information of this skin.
 *
 * @return - Your XML layout information.
 */

function getLayoutInfo() : XML
{
   var layout:XML = 
   <layout>		   
   	<resize>
   		<prefix>dash/node/fields/</prefix>		
   		<path>voter</path>
   		<property>x</property>
   		<property>y</property>
   	</resize>	      
   </layout>;
   return layout;
}