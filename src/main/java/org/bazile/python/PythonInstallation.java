package org.bazile.python;

import hudson.EnvVars;
import hudson.Extension;
import hudson.model.EnvironmentSpecific;
import hudson.model.Node;
import hudson.model.TaskListener;
import hudson.slaves.NodeSpecific;
import hudson.tools.ToolDescriptor;
import hudson.tools.ToolInstallation;
import hudson.tools.ToolInstaller;
import hudson.tools.ToolProperty;
import net.sf.json.JSONObject;
import org.jenkinsci.Symbol;
import org.kohsuke.stapler.DataBoundConstructor;
import org.kohsuke.stapler.StaplerRequest;

import javax.annotation.Nonnull;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

public class PythonInstallation extends ToolInstallation implements EnvironmentSpecific<PythonInstallation>, NodeSpecific<PythonInstallation> {
    private static final String DISPLAY_NAME = "Python";

    @DataBoundConstructor
    public PythonInstallation(@Nonnull String name, @Nonnull String home, List<? extends ToolProperty<?>> properties) {
        super(name, home, properties);
    }

    @Override
    public PythonInstallation forEnvironment(EnvVars environment) {
        return new PythonInstallation(getName(), environment.expand(getHome()), getProperties().toList());
    }

    @Override
    public PythonInstallation forNode(@Nonnull Node node, TaskListener taskListener) throws IOException, InterruptedException {
        return new PythonInstallation(getName(), translateFor(node, taskListener), getProperties().toList());
    }

    @Symbol("python")
    @Extension
    public static class DescriptorImpl extends ToolDescriptor<PythonInstallation> {

        public DescriptorImpl() {
            load();
        }

        @Override
        public String getDisplayName() {
            return DISPLAY_NAME;
        }

        @Override
        public List<? extends ToolInstaller> getDefaultInstallers() {
            return Collections.singletonList(new PythonInstaller(null));
        }

        @Override
        public boolean configure(StaplerRequest req, JSONObject json) throws hudson.model.Descriptor.FormException {
            boolean result = super.configure(req, json);

            save();

            return result;
        }
    }
}
