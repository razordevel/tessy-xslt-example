package xsltest;

import static java.lang.System.lineSeparator;
import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.gradle.api.DefaultTask;
import org.gradle.api.GradleException;
import org.gradle.api.UncheckedIOException;
import org.gradle.api.tasks.InputDirectory;
import org.gradle.api.tasks.InputFile;
import org.gradle.api.tasks.OutputDirectory;
import org.gradle.api.tasks.TaskAction;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.builder.Input;
import org.xmlunit.diff.Diff;

public class TestXslt extends DefaultTask {
    public static final String SOURCE_FOLDER            = "src/main/xslt/";
    public static final String TESTS_ROOT_FOLDER        = "src/test/xslt/";
    public static final String TESTS_OUTPUT_ROOT_FOLDER = "build/xsltOutput/";
    private String             xsltName;
    private File               xslt;
    private File               outputDir;
    private File               testsFolder;
    private Transformer        transformer;
    private Map<Path, Diff>    differences              = new LinkedHashMap<>();

    public String getXsltName() {
        return xsltName;
    }

    public void setXsltName(String xsltName) {
        this.xsltName = xsltName;
    }

    @InputFile
    public File getXslt() {
        if (xslt == null) {
            xslt = file(SOURCE_FOLDER + xsltName);
        }

        return xslt;
    }

    public void setXslt(File xslt) {
        this.xslt = xslt;
    }

    @InputDirectory
    public File getTestsFolder() {
        if (testsFolder == null) {
            testsFolder = file(TESTS_ROOT_FOLDER + removeExtension(xsltName));
        }

        return testsFolder;
    }

    public void setTestsFolder(File testsFolder) {
        this.testsFolder = testsFolder;
    }

    @OutputDirectory
    public File getOutputDir() {
        if (outputDir == null) {
            outputDir = file(TESTS_OUTPUT_ROOT_FOLDER + removeExtension(xsltName));
        }

        return outputDir;
    }

    private String removeExtension(String fileName) {
        return fileName.replaceFirst("[.][^.]+$", "");
    }

    public void setOutputDir(File outputDir) {
        this.outputDir = outputDir;
    }

    public File getOutput(Path input) {
        Path inputRelativeToRootTestFolder = getTestsFolder().toPath()
                                                             .relativize(input);
        return outputDir.toPath()
                        .resolve(inputRelativeToRootTestFolder)
                        .getParent()
                        .resolve("output.xml")
                        .toFile();
    }

    public File toXunit(final File inputFile) {
        final File outputFile = getOutput(inputFile.toPath());

        outputFile.getParentFile()
                  .mkdirs();

        FileOutputStream junit;
        try {
            junit = new FileOutputStream(outputFile);

            getLogger().info("transform " + String.valueOf(inputFile) + " -> " + String.valueOf(outputFile));
            getTransformer().transform(new StreamSource(new FileReader(inputFile)), new StreamResult(junit));
        } catch (FileNotFoundException | TransformerException | TransformerFactoryConfigurationError e) {
            throw new UncheckedIOException(e);
        }
        return outputFile;
    }

    public Transformer getTransformer()
        throws TransformerConfigurationException, FileNotFoundException, TransformerFactoryConfigurationError {
        if (transformer == null) {
            transformer = javax.xml.transform.TransformerFactory.newInstance()
                                                                .newTransformer(new StreamSource(new FileReader(xslt)));
        }

        return transformer;
    }

    public void testExample(File exampleDir) {
        File output = toXunit(exampleDir.toPath()
                                        .resolve("input.xml")
                                        .toFile());

        File expectedXml = exampleDir.toPath()
                                     .resolve("expected.xml")
                                     .toFile();
        Diff currentDiff = DiffBuilder.compare(Input.fromFile(output))
                                      .normalizeWhitespace()
                                      .withTest(Input.fromFile(expectedXml))
                                      .build();

        if (currentDiff.hasDifferences()) {
            differences.put(output.toPath(), currentDiff);
            StringBuilder sb = new StringBuilder();
            sb.append(lineSeparator())
              .append(exampleDir + ":")
              .append(lineSeparator())
              .append(currentDiff.toString())
              .append(lineSeparator())
              .append("Actual output at " + output.getAbsolutePath())
              .append(lineSeparator());
            getLogger().error(sb.toString());
        }

    }

    @TaskAction
    public void test() throws IOException {
        getLogger().info("use tests from " + String.valueOf(testsFolder) + ": ");
        for (File example : testsFolder.listFiles(File::isDirectory)) {
            getLogger().info(example.getName());
            testExample(example);
        }
        if (!differences.isEmpty()) {
            throw new GradleException("There are differences between actual and expected xml outputs");
        }
    }

    private File file(String path) {
        return getProject().file(path);
    }

}
