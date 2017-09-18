package org.bazile.jenkins.python;

import hudson.Extension;
import hudson.FilePath;
import hudson.Launcher;
import hudson.model.Node;
import hudson.model.TaskListener;
import hudson.tools.DownloadFromUrlInstaller;
import hudson.tools.ToolInstallation;
import org.bazile.jenkins.python.utils.Platform;
import org.kohsuke.stapler.DataBoundConstructor;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class PythonInstaller extends DownloadFromUrlInstaller {
    private static final List<String> AVAILABLE_VERSIONS = Arrays.asList("3.6.2", "3.5.4", "3.4.7", "3.3.6", "2.7.13");
    private static final String S3_BUCKET = "bazile.jenkins.python";
    private static final String POSTINSTALLER_SCRIPT = "postinstall.sh";

    @DataBoundConstructor
    public PythonInstaller(String id) {
        super(id);
    }

    @Override
    public FilePath performInstallation(ToolInstallation tool, Node node, TaskListener log) throws IOException, InterruptedException {

        final Installable installable = getCompatibleInstallable(node);
        if (installable == null) {
            throw new InstallationFailed("could not find installable");
        }

        final FilePath toolHome = preferredLocation(tool, node);
        if (this.isUpToDate(toolHome, installable)) {
            return toolHome;
        }

        if (toolHome.installIfNecessaryFrom(new URL(installable.url), log, String.format("Unpacking %s to %s on %s", installable.url, toolHome, node.getDisplayName()))) {
            toolHome.child(".timestamp").delete();
            FilePath base = this.findPullUpDirectory(toolHome);
            if (base != null && base != toolHome) {
                base.moveAllChildrenTo(toolHome);
            }

            toolHome.child(".installedFrom").write(installable.url, "UTF-8");
        }

        FilePath postinstaller = toolHome.child(POSTINSTALLER_SCRIPT);
        if (postinstaller.exists()) {
            Launcher launcher = node.createLauncher(log);
            launcher.launch()
                    .pwd(toolHome)
                    .cmds("bash", postinstaller.getName())
                    .stdout(log)
                    .join();
            postinstaller.delete();
        }

        return toolHome;
    }

    private Installable getCompatibleInstallable(Node node) throws IOException {
        Installable primitive = getInstallable();

        final String version = primitive.id;
        final Platform platform = Platform.detect(node);

        Installable installable = new Installable();
        installable.id = version;
        installable.name = primitive.name;
        installable.url = String.format("https://s3.amazonaws.com/%s/python-%s-%s.tar.gz", S3_BUCKET, version, platform);

        return installable;
    }

    @Extension
    public static final class DescriptorImpl extends DownloadFromUrlInstaller.DescriptorImpl<PythonInstaller> {

        @Override
        public String getDisplayName() {
            return Messages.InstallFromS3(S3_BUCKET);
        }

        @Override
        public List<? extends Installable> getInstallables() throws IOException {
            List<Installable> installables = new ArrayList<>();

            for (String version : AVAILABLE_VERSIONS) {
                final Installable installable = new Installable();
                installable.id = version;
                installable.name = String.format("Python %s", version);
                installables.add(installable);
            }

            return installables;
        }

        @Override
        public boolean isApplicable(Class<? extends ToolInstallation> toolType) {
            return toolType == PythonInstallation.class;
        }
    }

    private static class InstallationFailed extends RuntimeException {
        public InstallationFailed(String message) {
            super(message);
        }
    }
}
