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

/**
 * Returns the layout information of this skin.
 *
 * @return - Your XML layout information.
 */

function getLayoutInfo() : XML
{
   var layout:XML = 
   <layout>
	   <width>382</width>
	   <height>20</height>
	   <autoHideX>1</autoHideX>
	   <autoHideY>1</autoHideY>	
	   <spacer>1</spacer>
	   <linkpadding>10</linkpadding>		
	   <resize>
		   <path>dash/node/fields/media/controlBar/invalid</path>
		   <property>width</property>
	   </resize>				
	   <resize>
		   <path>dash/node/fields/media/controlBar/seekBar/control/button/seekWidth</path>
		   <property>width</property>
	   </resize>													
	   <resize>
		   <path>dash/node/fields/media/controlBar/seekBar/backgroundMC/backgroundGrad</path>
		   <property>width</property>
	   </resize>				
	   <resize>
		   <path>dash/node/fields/media/controlBar/seekBar/backgroundMC/background</path>
		   <property>width</property>
	   </resize>
	   <resize>
		   <path>dash/node/fields/media/controlBar/seekBar/playTime</path>
		   <property>x</property>
	   </resize>
	   <resize>
		   <path>dash/node/fields/media/controlBar/seekBar/textSeparator</path>
		   <property>x</property>
	   </resize>
	   <resize>
		   <path>dash/node/fields/media/controlBar/seekBar/totalTime</path>
		   <property>x</property>
	   </resize>
	   <resize>
		   <path>dash/node/fields/media/controlBar/seekBar/timeUnits</path>
		   <property>x</property>
	   </resize>
	   <resize>
		   <path>dash/node/fields/media/controlBar/volumeBar</path>
         <property>x</property>
	   </resize>
	   <resize>
		   <path>dash/node/fields/media/controlBar/minMaxNode</path>
         <property>x</property>
	   </resize>  
	   <resize>
		   <path>dash/node/fields/media/controlBar/toggleFullScreen</path>
         <property>x</property>
	   </resize>  
	   <resize>
		   <path>dash/node/fields/media/controlBar/menuButton</path>
         <property>x</property>
	   </resize>    
   </layout>;      
   return layout;
}