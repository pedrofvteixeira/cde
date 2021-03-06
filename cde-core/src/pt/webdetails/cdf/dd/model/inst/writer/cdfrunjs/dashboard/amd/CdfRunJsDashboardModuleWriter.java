/*!
 * Copyright 2002 - 2015 Webdetails, a Pentaho company. All rights reserved.
 *
 * This software was developed by Webdetails and is provided under the terms
 * of the Mozilla Public License, Version 2.0, or any later version. You may not use
 * this file except in compliance with the license. If you need a copy of the license,
 * please go to http://mozilla.org/MPL/2.0/. The Initial Developer is Webdetails.
 *
 * Software distributed under the Mozilla Public License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. Please refer to
 * the license for the specific language governing your rights and limitations.
 */

package pt.webdetails.cdf.dd.model.inst.writer.cdfrunjs.dashboard.amd;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import pt.webdetails.cdf.dd.CdeConstants;
import pt.webdetails.cdf.dd.model.core.writer.ThingWriteException;
import pt.webdetails.cdf.dd.model.inst.Dashboard;
import pt.webdetails.cdf.dd.model.inst.writer.cdfrunjs.dashboard.CdfRunJsDashboardWriteContext;
import pt.webdetails.cdf.dd.model.inst.writer.cdfrunjs.dashboard.CdfRunJsDashboardWriteResult;
import pt.webdetails.cdf.dd.render.ResourceMap;
import pt.webdetails.cdf.dd.structure.DashboardWcdfDescriptor;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static pt.webdetails.cdf.dd.CdeConstants.Writer.*;

public class CdfRunJsDashboardModuleWriter extends CdfRunJsDashboardWriter {
  protected static Log logger = LogFactory.getLog( CdfRunJsDashboardModuleWriter.class );

  public CdfRunJsDashboardModuleWriter( DashboardWcdfDescriptor.DashboardRendererType type ) {
    super( type );
  }

  /**
   * Writes the dashboard module to a provided builder object.
   *
   * @param builder the builder object to where the processed dashboard will be stored
   * @param ctx the dashboard context.
   * @param dash the dashboard to write.
   * @throws ThingWriteException
   */
  @Override
  public void write( CdfRunJsDashboardWriteResult.Builder builder, CdfRunJsDashboardWriteContext ctx, Dashboard dash )
    throws ThingWriteException {
    assert dash == ctx.getDashboard();

    // content resources
    ResourceMap resources;
    try {
      resources = getResourceRenderer( dash.getLayout( "TODO" ).getLayoutXPContext(), ctx )
        .renderResources( ctx.getOptions().getAliasPrefix() );
    } catch ( Exception ex ) {
      throw new ThingWriteException( "Error rendering resources.", ex );
    }
    // content layout, prepend the CSS code snippets
    final String layout;
    try {
      layout = ctx.replaceTokensAndAlias( this.writeCssCodeResources( resources ) )
        + ctx.replaceTokensAndAlias( this.writeLayout( ctx, dash ) ); // replaceTokens
    } catch ( Exception ex ) {
      throw new ThingWriteException( "Error rendering layout", ex );
    }
    // content components, get component AMD modules and write the components to the StringBuilder
    StringBuilder out = new StringBuilder();
    final Map<String, String> componentModules = this.writeComponents( ctx, dash, out );
    final String components = replaceAliasTagWithAlias( ctx.replaceHtmlAlias( ctx.replaceTokens( out.toString() ) ) );
    // content
    final String content = wrapRequireModuleDefinitions( layout, resources, componentModules, components, ctx );

    // Export
    builder
      .setTemplate( "" )
      .setHeader( "" )
      .setLayout( layout )
      .setComponents( components )
      .setContent( content )
      .setFooter( "" )
      .setLoadedDate( ctx.getDashboard().getSourceDate() );
  }

  /**
   * Replaces all alias tags contained in the provided content string.
   *
   * @param content the string containing some JavaScript sourcecode
   * @return the string with all alias tags replaced with the appropriate sourcecode
   */
  protected String replaceAliasTagWithAlias( String content ) {
    return content.replaceAll( CdeConstants.DASHBOARD_ALIAS_TAG, "\" + this._alias +\"" );
  }

  /**
   * Wraps the JavaScript code, contained in the input parameters, as a requirejs module definition.
   *
   * @param layout the dashboard's layout HTML sourcecode
   * @param resources the dashboard's resources
   * @param componentModules the dashboard component modules
   * @param components the dashboard's generated component JavaScript sourcecode, that creates components, to be wrapped
   * @param ctx the dashboard context
   * @return the string containing the dashboard module definition.
   */
  protected String wrapRequireModuleDefinitions(
      String layout,
      ResourceMap resources,
      Map<String, String> componentModules,
      String components,
      CdfRunJsDashboardWriteContext ctx ) {

    StringBuilder out = new StringBuilder();

    ArrayList<String> moduleIds = new ArrayList<String>(), // AMD module paths
        moduleClassNames = new ArrayList<String>(); // AMD module class names

    // Add default dashboard module ids and class names
    addDefaultDashboardModules( moduleIds, moduleClassNames );

    // store component AMD modules ids and class names
    Iterator it = componentModules.entrySet().iterator();
    Map.Entry pair;
    while ( it.hasNext() ) {
      pair = (Map.Entry) it.next();
      // Add component AMD module path
      moduleIds.add( (String) pair.getValue() );
      // Add component AMD module class name
      if ( !StringUtils.isEmpty( (String) pair.getKey() ) ) {
        moduleClassNames.add( (String) pair.getKey() );
      }
    }

    // write RequireJS module path configurations for external JS and CSS resources
    Map<String, String> fileResourceModules = writeFileResourcesRequireJSPathConfig( out, resources, ctx );

    // Add external resource module ids to the list
    moduleIds.addAll( fileResourceModules.keySet() );
    // Add external resource module class names to the list
    moduleClassNames.addAll( fileResourceModules.values() );

    // Output module paths and module class names
    writeRequireJsExecutionFunction( out, moduleIds, moduleClassNames );

    if ( ctx.getOptions().getAliasPrefix().contains( CdeConstants.DASHBOARD_ALIAS_TAG ) ) {
      out.append( MessageFormat.format(
          DASHBOARD_MODULE_START_EMPTY_ALIAS,
          ctx.getOptions().getContextConfiguration(),
          StringEscapeUtils.escapeJavaScript( layout.replace( NEWLINE, "" ) ) ) );
    } else {
      out.append( MessageFormat.format( DASHBOARD_MODULE_START, ctx.getOptions().getContextConfiguration() ) )
          .append( MessageFormat.format( DASHBOARD_MODULE_LAYOUT,
            StringEscapeUtils.escapeJavaScript( layout.replace( NEWLINE, "" ) ) ) );
    }

    final String jsCodeSnippets = writeJsCodeResources( resources );

    out.append( DASHBOARD_MODULE_RENDERER ).append( NEWLINE )
      .append( DASHBOARD_MODULE_SETUP_DOM ).append( NEWLINE )
      .append( MessageFormat.format( DASHBOARD_MODULE_PROCESS_COMPONENTS,
        jsCodeSnippets.length() > 0 ? jsCodeSnippets + NEWLINE + components : components ) )
      .append( DASHBOARD_MODULE_STOP ).append( NEWLINE )
      .append( DEFINE_STOP );

    return out.toString();
  }

  /**
   * Writes the RequireJS 'define' JavaScript function sourcecode to the given string builder.
   *
   * @param out the string builder to where the sourcecode will be written
   * @param ids the array list containing all module ids
   * @param classNames the array list containing all module class names
   */
  @Override
  protected void writeRequireJsExecutionFunction( StringBuilder out, List<String> ids, List<String> classNames ) {
    // remove empty external resource module class names from the list
    Iterator<String> i = classNames.iterator();
    while ( i.hasNext() ) {
      String className = i.next();
      if ( StringUtils.isEmpty( className ) ) {
        i.remove();
      }
    }
    // Output module paths and module class names
    out.append( MessageFormat.format( DEFINE_START,
        StringUtils.join( ids, "', '" ),
        StringUtils.join( classNames, ", " ) ) );
  }

}
