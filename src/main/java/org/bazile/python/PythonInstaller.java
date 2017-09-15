package org.bazile.python;

import hudson.Extension;
import hudson.FilePath;
import hudson.Launcher;
import hudson.model.Computer;
import hudson.model.Node;
import hudson.model.TaskListener;
import hudson.tools.DownloadFromUrlInstaller;
import hudson.tools.ToolInstallation;
import org.kohsuke.stapler.DataBoundConstructor;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class PythonInstaller extends DownloadFromUrlInstaller {
    private static final String DISPLAY_NAME = "Install from S3";
    private static final String RUNTIME_URL = "http://s3.amazonaws.com/bazile.jenkins.python-plugin/python-{{version}}-{{platform}}.tar.gz";
    private static final String POSTINSTALLER_SCRIPT = "postinstall.bash";
    private static final String PLATFORM_UNKNOWN = "unknown";

    @DataBoundConstructor
    public PythonInstaller(String id) {
        super(id);
    }

    @Override
    public FilePath performInstallation(ToolInstallation tool, Node node, TaskListener log) throws IOException, InterruptedException {
        FilePath toolHome = super.performInstallation(tool, node, log);
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

    @Extension
    public static final class DescriptorImpl extends DownloadFromUrlInstaller.DescriptorImpl<PythonInstaller> {

        private static final String PLATFORM_LINUX = "linux";
        private static final String PLATFORM_MACOS = "macos";

        @Override
        public String getDisplayName() {
            return DISPLAY_NAME;
        }

        @Override
        public List<? extends Installable> getInstallables() throws IOException {
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
            installable.url = RUNTIME_URL.replace("{{version}}", version).replace("{{platform}}", getPlatformName());
            installable.name = String.format("Python %s", version);
            return installable;
        }

        private String getPlatformName() {
            Computer currentComputer = Computer.currentComputer();
            if (currentComputer == null) {
                return PLATFORM_UNKNOWN;
            }

            String raw = "";
            try {
                raw = currentComputer.getSystemProperties().get("os.name").toString().toLowerCase();
            }
            catch (IOException|InterruptedException e) {/* do nothing */}

            if (raw.contains("os x")) {
                return PLATFORM_MACOS;
            }

            if (raw.contains("linux")) {
                return PLATFORM_LINUX;
            }

            return PLATFORM_UNKNOWN;
        }

        @Override
        public boolean isApplicable(Class<? extends ToolInstallation> toolType) {
            return toolType == PythonInstallation.class;
        }
    }
}
