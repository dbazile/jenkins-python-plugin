package org.bazile.python;

import hudson.Extension;
import hudson.FilePath;
import hudson.model.Node;
import hudson.model.TaskListener;
import hudson.tools.DownloadFromUrlInstaller;
import hudson.tools.ToolInstallation;
import org.kohsuke.stapler.DataBoundConstructor;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class PythonInstaller extends DownloadFromUrlInstaller {

    @DataBoundConstructor
    public PythonInstaller(String id) {
        super(id);
    }

    @Override
    public FilePath performInstallation(ToolInstallation tool, Node node, TaskListener log) throws IOException, InterruptedException {
        FilePath filePath = super.performInstallation(tool, node, log);

        System.out.println("inside performInstallation");
        return filePath;
    }

    @Extension
    public static final class DescriptorImpl extends DownloadFromUrlInstaller.DescriptorImpl<PythonInstaller> {

        private static final String URL_TEMPLATE = "http://s3.amazonaws.com/bazile.dev.jenkins-python-plugin.runtimes/python-%s.tar.gz";

        @Override
        public String getDisplayName() {
            return "Install from S3";
        }

        @Override
        public List<? extends Installable> getInstallables() throws IOException {
            System.out.println("\n\n----\ngetInstallables() invoked\n----\n\n");
            List<Installable> installables = new ArrayList<>();

            installables.add(createInstallable("3.6.2"));
            installables.add(createInstallable("3.5.4"));
            installables.add(createInstallable("3.4.7"));
            installables.add(createInstallable("3.3.6"));
            installables.add(createInstallable("2.7.13"));

            return installables;
        }

        private Installable createInstallable(String version) {
            Installable installable = new Installable();
            installable.id = version;
            installable.url = String.format(URL_TEMPLATE, version);
            installable.name = String.format("Python %s", version);
            return installable;
        }

        @Override
        public String getDescriptorUrl() {
            return super.getDescriptorUrl();
        }

        @Override
        public boolean isApplicable(Class<? extends ToolInstallation> toolType) {
            return toolType == PythonInstallation.class;
        }
    }
}
